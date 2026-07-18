# Create the CF subdomain NS records pointing to DO nameservers
resource "cloudflare_dns_record" "ns1" {
  for_each = toset(["ns1.digitalocean.com", "ns2.digitalocean.com", "ns3.digitalocean.com"])
  zone_id  = data.cloudflare_zone.this.id
  name     = "aqualog"
  content  = each.value
  type     = "NS"
  ttl      = 1
  proxied  = false
}

# Create a new domain
resource "digitalocean_domain" "this" {
  name = "aqualog.cylindric.net"
}

resource "digitalocean_record" "www" {
  domain = digitalocean_domain.this.id
  type   = "A"
  name   = "www"
  value  = digitalocean_loadbalancer.public.ip
  ttl    = 60
}

resource "digitalocean_record" "auth" {
  domain = digitalocean_domain.this.id
  type   = "A"
  name   = "auth"
  value  = digitalocean_loadbalancer.public.ip
  ttl    = 60
}

resource "digitalocean_record" "api" {
  domain = digitalocean_domain.this.id
  type   = "A"
  name   = "api"
  value  = digitalocean_loadbalancer.public.ip
  ttl    = 60
}
