locals {
  swarm_rules = []
  # swarm_rules = [
  #   { protocol = "tcp", port_range = 22, tags = ["aqualog"] },
  #   { protocol = "tcp", port_range = 2377, tags = ["aqualog"] },
  #   { protocol = "tcp", port_range = 7946, tags = ["aqualog"] },
  #   { protocol = "udp", port_range = 7946, tags = ["aqualog"] },
  #   { protocol = "udp", port_range = 4789, tags = ["aqualog"] },
  # ]
}

resource "digitalocean_droplet" "swarm" {
  count             = 0
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
