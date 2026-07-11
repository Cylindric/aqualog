data "cloudflare_zone" "this" {
  filter = {
    name = "cylindric.net"
  }
}

# Create a DNS records
resource "cloudflare_dns_record" "aqualog" {
  zone_id = data.cloudflare_zone.this.id
  name    = "aqualog.home.cylindric.net"
  type    = "CNAME"
  content = "home.cylindric.net"
  ttl     = 1
  proxied = true
}

resource "cloudflare_dns_record" "aqualog_api" {
  zone_id = data.cloudflare_zone.this.id
  name    = "api.aqualog.home.cylindric.net"
  type    = "CNAME"
  content = "home.cylindric.net"
  ttl     = 1
  proxied = true
}

resource "cloudflare_dns_record" "aqualog_auth" {
  zone_id = data.cloudflare_zone.this.id
  name    = "auth.aqualog.home.cylindric.net"
  type    = "CNAME"
  content = "home.cylindric.net"
  ttl     = 1
  proxied = true
}

resource "cloudflare_dns_record" "auth" {
  zone_id = data.cloudflare_zone.this.id
  name    = "auth.home.cylindric.net"
  type    = "CNAME"
  content = "home.cylindric.net"
  ttl     = 1
  proxied = true
}
