terraform {
  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = "2026.5.0"
    }
  }
}

provider "authentik" {
  url   = "http://127.0.0.1:9000"
  token = "ruqqgUUwubnKOIrR5nfWMSf0ba4qk4vMqX6PwoXxiGiRp2JpY1TD29EQZ6dR"
  # Optionally set insecure to ignore TLS Certificates
  # insecure = true
  # Optionally add extra headers
  # headers {
  #   X-my-header = "foo"
  # }
}