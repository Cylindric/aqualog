data "authentik_property_mapping_provider_scope" "scope" {
  for_each = toset(["openid", "email", "profile", "offline_access"])
  managed  = "goauthentik.io/providers/oauth2/scope-${each.value}"
}

data "authentik_flow" "default_authorization_flow" {
  slug = "default-provider-authorization-implicit-consent"
}

data "authentik_flow" "default_invalidation_flow" {
  slug = "default-provider-invalidation-flow"
}

data "authentik_stage" "default_authentication_login" {
  name = "default-authentication-login"
}

data "authentik_stage" "default_authentication_password" {
  name = "default-authentication-password"
}

data "authentik_certificate_key_pair" "authentik" {
  name = "authentik Self-signed Certificate"
}


# terraform import 'authentik_group.users' '4321da1f-0428-472c-8fbf-62525b724739'
resource "authentik_group" "users" {
  name         = "${var.aqualog_app_title} User Group"
  is_superuser = false
}

# terraform import 'authentik_flow.aqualog-authentication-flow' 'aqualog-authentication-flow'
resource "authentik_flow" "aqualog-authentication-flow" {
  name               = "aqualog-authentication-flow"
  title              = "${var.aqualog_app_title} Login"
  slug               = "aqualog-authentication-flow"
  designation        = "authentication"
  authentication     = "none"
  layout             = "sidebar_left"
  policy_engine_mode = "any"
  compatibility_mode = true
  denied_action      = "message_continue"
}

# terraform import 'authentik_flow.aqualog-enrollment-flow' 'aqualog-enrollment-flow'
resource "authentik_flow" "aqualog-enrollment-flow" {
  name               = "aqualog-enrollment-flow"
  title              = "${var.aqualog_app_title} Registration"
  slug               = "aqualog-enrollment-flow"
  policy_engine_mode = "any"
  designation        = "enrollment"
  compatibility_mode = true
}

# terraform import 'authentik_stage_identification.authentication_identification' 'fc924a2c-39df-444b-b8e3-9920bc77f8f5'
resource "authentik_stage_identification" "authentication_identification" {
  name                      = "aqualog-authentication-identification"
  user_fields               = ["email"]
  password_stage            = data.authentik_stage.default_authentication_password.id
  case_insensitive_matching = true
  show_source_labels        = false
  show_matched_user         = true
  enrollment_flow           = authentik_flow.aqualog-enrollment-flow.uuid
}

resource "authentik_flow_stage_binding" "custom_authentication_flow" {
  for_each = {
    "default-authentication-identification" = {
      stage = authentik_stage_identification.authentication_identification.id
      order = 10
    },
    "default-authentication-login" = {
      stage = data.authentik_stage.default_authentication_login.id
      order = 100
    }
  }

  stage  = each.value.stage
  order  = each.value.order
  target = authentik_flow.aqualog-authentication-flow.uuid
}

# terraform import 'authentik_provider_oauth2.backend' 4
resource "authentik_provider_oauth2" "backend" {
  name                = var.aqualog_app_title
  client_id           = var.aqualog_client_id
  client_type         = "public"
  grant_types         = ["authorization_code", "refresh_token"]
  authorization_flow  = data.authentik_flow.default_authorization_flow.id
  authentication_flow = authentik_flow.aqualog-authentication-flow.uuid
  invalidation_flow   = data.authentik_flow.default_invalidation_flow.id
  property_mappings   = [for mapping in data.authentik_property_mapping_provider_scope.scope : mapping.id]
  signing_key         = data.authentik_certificate_key_pair.authentik.id
  allowed_redirect_uris = [
    {
      matching_mode     = "strict",
      redirect_uri_type = "authorization",
      url               = var.aqualog_auth_callback_url,
    },
    {
      matching_mode     = "strict",
      redirect_uri_type = "authorization",
      url               = var.aqualog_test_token_callback_url,
    }
  ]

  depends_on = [authentik_flow_stage_binding.custom_authentication_flow]
}

# terraform import 'authentik_application.backend' 'aqualog'
resource "authentik_application" "backend" {
  name              = var.aqualog_app_title
  slug              = "aqualog"
  group             = var.aqualog_app_title
  meta_icon         = "favicon.png"
  meta_publisher    = var.aqualog_app_title
  protocol_provider = authentik_provider_oauth2.backend.id
  meta_launch_url   = var.aqualog_app_url
}

# terraform import 'authentik_policy_binding.aqualog-access' '33607e61-0a27-4155-a5cc-a1e0c9710ad7'
resource "authentik_policy_binding" "aqualog-access" {
  target = authentik_application.backend.uuid
  group  = authentik_group.users.id
  order  = 0
}

# terraform import 'authentik_stage_email.email_account_confirmation' '631b12ff-e631-479b-8df6-7f3749fe23ca'
resource "authentik_stage_email" "email_account_confirmation" {
  name                     = "aqualog-email-account-confirmation"
  activate_user_on_success = true
  subject                  = "${var.aqualog_app_title} Account Confirmation"
  template                 = "email/account_confirmation.html"
  use_global_settings      = true
}

resource "authentik_stage_prompt_field" "enrollment_field" {
  for_each = {
    for field in [
      {
        field_key = "email"
        label     = "Email"
        type      = "email"
        order     = 10
      },
      {
        field_key = "password"
        label     = "Password"
        type      = "password"
        order     = 20
      },
      {
        field_key = "password_repeat"
        label     = "Password (repeat)"
        type      = "password"
        order     = 30
      },
    ] : field.field_key => field
  }

  field_key = each.value.field_key
  name      = each.key
  label     = each.value.label
  type      = each.value.type
  order     = each.value.order
}

# terraform import authentik_stage_prompt.custom_enrollment_prompt 1053df80-c025-4f3a-ac7f-9cb997af15ba
resource "authentik_stage_prompt" "custom_enrollment_prompt" {
  name                = "aqualog-enrollment-form"
  fields              = [for field in authentik_stage_prompt_field.enrollment_field : field.id]
  validation_policies = [authentik_policy_expression.set_username_to_email.id]
}

# terraform import authentik_stage_user_write.enrollment_user_write a501b14e-98c6-45c8-a279-eab4adc0e380
resource "authentik_stage_user_write" "enrollment_user_write" {
  name                     = "aqualog-enrollment-user-write"
  create_users_as_inactive = true
  user_path_template       = "users"
  create_users_group       = authentik_group.users.id
}

locals {
  aqualog-enrollment-flow_stages = [
    authentik_stage_prompt.custom_enrollment_prompt,
    authentik_stage_user_write.enrollment_user_write,
    authentik_stage_email.email_account_confirmation
  ]
}

resource "authentik_flow_stage_binding" "aqualog-enrollment-flow" {
  count = length(local.aqualog-enrollment-flow_stages)

  stage  = local.aqualog-enrollment-flow_stages[count.index].id
  order  = (count.index + 1) * 10
  target = authentik_flow.aqualog-enrollment-flow.uuid
}

# terraform import 'authentik_policy_expression.set_username_to_email' 'b6c0026f-46df-4ae7-9c53-be6a11feaa43'
resource "authentik_policy_expression" "set_username_to_email" {
  name       = "Set username to email"
  expression = <<EOT
request.context["prompt_data"]["username"] = request.context["prompt_data"]["email"]
return True
EOT
}
