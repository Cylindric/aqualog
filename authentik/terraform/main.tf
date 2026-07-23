data "authentik_flow" "default-provider-authorization-implicit-consent" {
  slug = "default-provider-authorization-implicit-consent"
}

data "authentik_flow" "default-invalidation-flow" {
  slug = "default-invalidation-flow"
}


resource "authentik_brand" "this" {
  domain           = "localhost:8000"
  default          = false
  branding_title   = "AquaLog"
  branding_favicon = "favicon.png"
  branding_logo    = "logo-login.png"
}
