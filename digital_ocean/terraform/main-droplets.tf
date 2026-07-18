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
  name   = "default-lon1"
}

resource "digitalocean_droplet_autoscale" "this" {
  name = "aqualog"

  config {
    min_instances             = 1
    max_instances             = 1
    target_cpu_utilization    = 0.95
    target_memory_utilization = 0.95
    cooldown_minutes          = 5
  }

  droplet_template {
    size               = "s-2vcpu-2gb"
    region             = data.digitalocean_region.this.slug
    image              = "ubuntu-26-04-x64"
    tags               = [digitalocean_tag.this.id]
    ssh_keys           = [digitalocean_ssh_key.this.id]
    with_droplet_agent = true
    ipv6               = false
    user_data          = "\n#cloud-config\nruncmd:\n- apt-get update\n- apt-get install -y stress-ng\n"
    public_networking  = true
    project_id         = digitalocean_project.this.id
    vpc_uuid           = data.digitalocean_vpc.this.id
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

  # direct forward for authentik
  /*
  forwarding_rule {
    entry_port     = 8000
    entry_protocol = "http"

    target_port     = 8000
    target_protocol = "http"
  }

  # direct forward for backend
  forwarding_rule {
    entry_port     = 8001
    entry_protocol = "http"

    target_port     = 8001
    target_protocol = "http"
  }

  # direct forward for frontend
  forwarding_rule {
    entry_port     = 8002
    entry_protocol = "http"

    target_port     = 8002
    target_protocol = "http"
  }
  */
  healthcheck {
    port     = 22
    protocol = "tcp"
  }

  droplet_tag = digitalocean_tag.this.id
}

data "digitalocean_droplets" "this" {
  filter {
    key    = "tags"
    values = ["aqualog"]
  }
}

output "droplets" {
  value = data.digitalocean_droplets.this.droplets[*].ipv4_address
}