# Create an application with a provider attached and policies applied

data "authentik_flow" "aqualog-api-authorization-flow" {
  slug = "default-provider-authorization-implicit-consent"
}

data "authentik_flow" "aqualog-api-invalidation-flow" {
  slug = "default-invalidation-flow"
}

resource "authentik_provider_oauth2" "aqualog-api" {
  name      = "aqualog-api"
  client_id = "aqualog-api"
  invalidation_flow = data.authentik_flow.aqualog-api-invalidation-flow.id
  authorization_flow = data.authentik_flow.aqualog-api-authorization-flow.id
  allowed_redirect_uris = [
    {
      matching_mode = "strict",
      redirect_uri_type = "authorization",
      url           = "http://localhost:8000",
    },
    {
      matching_mode = "strict",
      redirect_uri_type = "authorization",
      url           = "http://127.0.0.1:8000",
    },    
  ]
}

resource "authentik_application" "aqualog-api" {
  name              = "aqualog-api"
  slug              = "aqualog-api"
  protocol_provider = authentik_provider_oauth2.aqualog-api.id
}

# resource "authentik_policy_expression" "policy" {
#   name       = "example"
#   expression = "return True"
# }

# resource "authentik_policy_binding" "app-access" {
#   target = authentik_application.name.uuid
#   policy = authentik_policy_expression.policy.id
#   order  = 0
# }

# resource "authentik_application" "name" {
#   name              = "example-app"
#   slug              = "example-app"
#   protocol_provider = authentik_provider_oauth2.name.id
# }
