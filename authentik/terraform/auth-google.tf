# Based on this: https://docs.goauthentik.io/users-sources/sources/social-logins/google/workspace/
data "authentik_certificate_key_pair" "google" {
  name = var.google_cert_name
}

data "authentik_flow" "default-source-pre-authentication" {
  slug = "default-source-pre-authentication"
}

data "authentik_flow" "default-source-authentication" {
  slug = "default-source-authentication"
}

data "authentik_flow" "default-source-enrollment" {
  slug = "default-source-enrollment"
}

resource "authentik_source_saml" "google" {
  name                    = "google"
  slug                    = "google"
  authentication_flow     = data.authentik_flow.default-source-authentication.id
  enrollment_flow         = data.authentik_flow.default-source-enrollment.id
  pre_authentication_flow = data.authentik_flow.default-source-pre-authentication.id
  sso_url                 = var.google_sso_url
  force_authn             = false
  issuer                  = "https://auth.home.cylindric.net/source/saml/google/metadata/"
  name_id_policy          = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
  allow_idp_initiated     = true
  signed_response         = true
  verification_kp         = data.authentik_certificate_key_pair.google.id

}