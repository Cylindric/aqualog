terraform {
  required_providers {
    acme = {
      source  = "vancluever/acme"
      version = "~> 2.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Needs the following permissions:
#   Account API Tokens Read
#   Account API Tokens Write
#   Zone Read

variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
  sensitive   = true
}
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}


# Set the variable value in *.tfvars file
# or using -var="do_token=..." CLI option
variable "do_token" {}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

variable "acme_email" {
  description = "Email address for ACME registration"
  type        = string
}

variable "acme_endpoint" {
  description = "ACME server endpoint"
  type        = string
  default     = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

provider "acme" {
  server_url = var.acme_endpoint
}

resource "acme_registration" "reg" {
  email_address = var.acme_email
}
