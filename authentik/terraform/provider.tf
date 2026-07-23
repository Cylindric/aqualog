terraform {
  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = "2026.5.0"
    }
  }
}

variable "authentik_url" {
  type        = string
  description = "The URL of the authentik instance"
}

variable "authentik_token" {
  type        = string
  description = "The API token for the authentik instance"
}

provider "authentik" {
  url   = var.authentik_url
  token = var.authentik_token
  # Optionally set insecure to ignore TLS Certificates
  # insecure = true
}