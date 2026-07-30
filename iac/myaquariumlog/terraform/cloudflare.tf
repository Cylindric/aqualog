data "cloudflare_zone" "aqualog" {
  filter = {
    name = "myaquariumlog.com"
  }
}

# Create the DNS records
resource "cloudflare_dns_record" "droplet" {
  zone_id = data.cloudflare_zone.aqualog.id
  name    = "droplet.myaquariumlog.com"
  type    = "A"
  content = digitalocean_reserved_ip.aqualog.ip_address
  ttl     = 1
  proxied = true
}

resource "cloudflare_dns_record" "www" {
  zone_id = data.cloudflare_zone.aqualog.id
  name    = "www.myaquariumlog.com"
  type    = "CNAME"
  content = "droplet.myaquariumlog.com"
  ttl     = 1
  proxied = true
}

resource "cloudflare_dns_record" "auth" {
  zone_id = data.cloudflare_zone.aqualog.id
  name    = "auth.myaquariumlog.com"
  type    = "CNAME"
  content = "droplet.myaquariumlog.com"
  ttl     = 1
  proxied = true
}

resource "cloudflare_dns_record" "api" {
  zone_id = data.cloudflare_zone.aqualog.id
  name    = "api.myaquariumlog.com"
  type    = "CNAME"
  content = "droplet.myaquariumlog.com"
  ttl     = 1
  proxied = true
}
