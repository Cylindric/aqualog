data "digitalocean_region" "this" {
  slug = "lon1"
}

data "digitalocean_vpc" "this" {
  name = "default-lon1"
}

resource "digitalocean_tag" "aqualog" {
  name = "aqualog"
}

# terraform import digitalocean_ssh_key.mykey 263654
resource "digitalocean_ssh_key" "aqualog" {
  name       = "aqualog"
  public_key = file("~/.ssh/id_rsa.pub")
}

data "digitalocean_droplet" "aqualog" {
  name = "aqualog"
}
# terraform import digitalocean_droplet.aqualog 585879740
# resource "digitalocean_droplet" "aqualog" {
#   name              = "aqualog"
#   size              = "s-2vcpu-2gb"
#   region            = data.digitalocean_region.this.slug
#   image             = "ubuntu-26-04-x64"
#   tags              = [digitalocean_tag.aqualog.id]
#   ssh_keys          = [digitalocean_ssh_key.aqualog.id]
#   droplet_agent     = true
#   monitoring        = true
#   ipv6              = false
#   public_networking = true
#   vpc_uuid          = data.digitalocean_vpc.this.id
#   backups           = true
#   backup_policy {
#     plan = "daily"
#     hour = 8
#   }
# }

resource "digitalocean_droplet" "swarm" {
  count             = 2
  name              = "aqualog-${count.index}"
  size              = "s-1vcpu-1gb"
  region            = data.digitalocean_region.this.slug
  image             = "ubuntu-26-04-x64"
  tags              = [digitalocean_tag.aqualog.id]
  ssh_keys          = [digitalocean_ssh_key.aqualog.id]
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

resource "digitalocean_reserved_ip" "aqualog" {
  droplet_id = data.digitalocean_droplet.aqualog.id
  region     = data.digitalocean_droplet.aqualog.region
}

# terraform import digitalocean_firewall.this dd8fa820-fc6b-4635-89d0-fa348605fb88
resource "digitalocean_firewall" "aqualog" {
  name = "aqualog-fw"
  tags = [digitalocean_tag.aqualog.id]

  inbound_rule {
    protocol   = "tcp"
    port_range = "22"
    source_addresses = [
      "0.0.0.0/0", # until we have an alternative deploy mechanism in the GitHub Actions workflow, we need to allow all IPs to connect to port 22
      var.cylcorp_ip_address
    ]
  }

  inbound_rule {
    protocol   = "tcp"
    port_range = "443"
    source_addresses = [
      "0.0.0.0/0"
    ]
  }

  inbound_rule {
    protocol   = "tcp"
    port_range = "5432"
    source_addresses = [
      var.cylcorp_ip_address
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
  outbound_rule {
    protocol   = "tcp"
    port_range = "587"
    destination_addresses = [
      "0.0.0.0/0"
    ]
  }
  outbound_rule {
    protocol   = "tcp"
    port_range = "2525"
    destination_addresses = [
      "0.0.0.0/0"
    ]
  }

  # Standard NTP port for time synchronization
  outbound_rule {
    protocol   = "udp"
    port_range = "123"
    destination_addresses = [
      "0.0.0.0/0"
    ]
  }
  # NTS Port for secure time synchronization
  outbound_rule {
    protocol   = "tcp"
    port_range = "4460"
    destination_addresses = [
      "0.0.0.0/0"
    ]
  }

  dynamic inbound_rule {
    for_each = local.bidirectional_rules
    content {
      protocol = inbound_rule.value["protocol"]
      port_range = inbound_rule.value["port_range"]
      source_tags = inbound_rule.value["tags"]
    }
  }
  dynamic outbound_rule {
    for_each = local.bidirectional_rules
    content {
      protocol = outbound_rule.value["protocol"]
      port_range = outbound_rule.value["port_range"]
      destination_tags = outbound_rule.value["tags"]
    }
  }
}

locals {
  bidirectional_rules = [
    { protocol = "tcp", port_range = 22, tags = ["aqualog"] },
    { protocol = "tcp", port_range = 2377, tags = ["aqualog"] },
    { protocol = "tcp", port_range = 7946, tags = ["aqualog"] },
    { protocol = "udp", port_range = 7946, tags = ["aqualog"] },
    { protocol = "udp", port_range = 4789, tags = ["aqualog"] },
  ]
}