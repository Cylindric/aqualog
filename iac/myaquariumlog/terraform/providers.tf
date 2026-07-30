terraform {
  required_version = "1.15.8"

  cloud {
    organization = "MyAquariumLog"
    workspaces {
      name = "aqualog"
    }
  }

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_token
}

provider "digitalocean" {
  token = var.digitalocean_token
}
