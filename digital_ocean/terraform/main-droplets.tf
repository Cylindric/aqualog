resource "digitalocean_certificate" "this" {
  name = "aqualog"
  type = "lets_encrypt"
  domains = [
    "www.aqualog.cylindric.net",
    "api.aqualog.cylindric.net",
    "auth.aqualog.cylindric.net"
  ]
  lifecycle {
    create_before_destroy = true
  }
}

resource "digitalocean_ssh_key" "this" {
  name       = "aqualog"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "digitalocean_tag" "this" {
  name = "aqualog"
}

data "digitalocean_vpc" "this" {
  name = "default-lon1"
}

resource "digitalocean_droplet" "this" {
  name              = "aqualog"
  size              = "s-2vcpu-2gb"
  region            = data.digitalocean_region.this.slug
  image             = "ubuntu-26-04-x64"
  tags              = [digitalocean_tag.this.id]
  ssh_keys          = [digitalocean_ssh_key.this.id]
  droplet_agent     = true
  monitoring        = true
  ipv6              = false
  public_networking = true
  vpc_uuid          = data.digitalocean_vpc.this.id
  backups           = true
  backup_policy {
    plan = "daily"
    hour = 8
  }
}

resource "digitalocean_loadbalancer" "public" {
  name   = "aqualog-lb"
  region = data.digitalocean_region.this.slug

  forwarding_rule {
    entry_port     = 443
    entry_protocol = "http2"

    target_port     = 80
    target_protocol = "http"

    certificate_name = digitalocean_certificate.this.name
  }

  healthcheck {
    port     = 80
    protocol = "http"
    path     = "/"
  }

  droplet_tag = digitalocean_tag.this.id
}

variable "cylcorp_ip_address" {
  description = "Cylcorp IP address"
  type        = string
  sensitive   = true
}

resource "digitalocean_firewall" "this" {
  name = "aqualog-fw"
  tags = [digitalocean_tag.this.id]

  inbound_rule {
    protocol   = "tcp"
    port_range = "22"
    source_addresses = [
      "0.0.0.0/0", # until we have an alternative deploy mechanism in the GitHub Actions workflow, we need to allow all IPs to connect to port 22
    var.cylcorp_ip_address]
  }

  inbound_rule {
    protocol   = "tcp"
    port_range = "80"
    source_addresses = [
      "10.106.0.3/20", # DigitalOcean Load Balancer IP address range
      digitalocean_loadbalancer.public.ip
    ]
  }

  outbound_rule {
    protocol   = "tcp"
    port_range = "80"
    destination_addresses = [
      "0.0.0.0/0"
    ]
  }
  outbound_rule {
    protocol   = "udp"
    port_range = "53"
    destination_addresses = [
      "0.0.0.0/0"
    ]
  }
  outbound_rule {
    protocol   = "tcp"
    port_range = "443"
    destination_addresses = [
      "0.0.0.0/0"
    ]
  }
}

output "droplets" {
  value = digitalocean_droplet.this.ipv4_address
}