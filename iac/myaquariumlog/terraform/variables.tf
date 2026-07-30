variable "cloudflare_token" {
  description = "Cloudflare API token"
  type        = string
  sensitive   = true
}

variable "digitalocean_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
}

variable "cylcorp_ip_address" {
  description = "Cylcorp IP address"
  type        = string
}

variable "digitalocean_ssh_public_key" {
  description = "DigitalOcean SSH public key"
  type        = string
}