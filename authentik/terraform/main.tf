data "authentik_flow" "default-provider-authorization-implicit-consent" {
  slug = "default-provider-authorization-implicit-consent"
}

data "authentik_flow" "default-invalidation-flow" {
  slug = "default-invalidation-flow"
}

# terraform import 'authentik_brand.aqualog' '64a5ccd8-ed76-44ac-81d8-6a85fff23fc5'
# terraform import -var-file=dev.tfvars 'authentik_brand.aqualog' '67c60398-b573-43e3-b1cf-ccbfd5ca1bb8'
resource "authentik_brand" "aqualog" {
  domain                           = var.aqualog_brand_domain
  default                          = false
  branding_title                   = var.aqualog_app_title
  branding_default_flow_background = "aqualog/background1.png"
  branding_favicon                 = "aqualog/favicon.png"
  branding_logo                    = "aqualog/logo-login.png"
  flow_authentication              = authentik_flow.aqualog-authentication-flow.uuid
}
