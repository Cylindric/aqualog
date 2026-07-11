data "authentik_brand" "this" {
  domain = "authentik-default"
}
# terraform state show data.authentik_brand.this
# terraform import 'authentik_brand.original' 7c95cd0a-f301-4824-a25d-f1cee5d3d990

data "authentik_flow" "default-authentication" {
  slug = "default-authentication-flow"
}

data "authentik_flow" "default-invalidation" {
  slug = "default-invalidation-flow"
}

data "authentik_flow" "default-user-settings" {
  slug = "default-user-settings-flow"
}

resource "authentik_brand" "original" {
  domain              = "authentik-default"
  default             = false
  branding_title      = "authentik"
  branding_favicon    = "/static/dist/assets/icons/icon.png"
  branding_logo       = "/static/dist/assets/icons/icon_left_brand.svg"
  flow_authentication = data.authentik_flow.default-authentication.id
  flow_invalidation   = data.authentik_flow.default-invalidation.id
  flow_user_settings  = data.authentik_flow.default-user-settings.id
}


data "authentik_certificate_key_pair" "this" {
  name = "authentik"
}

resource "authentik_brand" "this" {
  domain           = "auth.home.cylindric.net"
  default          = true
  branding_title   = "CylCorpAuth"
  branding_favicon = "/static/dist/assets/icons/icon.png"
  branding_logo    = "/static/dist/assets/icons/icon_left_brand.svg"
  web_certificate  = data.authentik_certificate_key_pair.this.id

  depends_on = [authentik_brand.original]
}
