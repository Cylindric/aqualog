data "digitalocean_region" "this" {
  slug = "lon1"
}

resource "digitalocean_project" "this" {
  name        = "AquaLog"
  description = "AquaLog Aquatics Monitoring"
  purpose     = "Web Application"
  environment = "Staging"

    
  resources = [
    # digitalocean_kubernetes_cluster.this.id
    digitalocean_domain.this.urn,
    digitalocean_loadbalancer.public.urn
  ]
}

data "cloudflare_zone" "this" {
  filter = {
    name = "cylindric.net"
  }
}

data "cloudflare_account_api_token_permission_groups_list" "zone_dns_settings_read" {
  account_id = data.cloudflare_zone.this.account.id
  name       = "Zone DNS Settings Read"
}

data "cloudflare_account_api_token_permission_groups_list" "dns_write" {
  account_id = data.cloudflare_zone.this.account.id
  name       = "DNS Write"
}

data "cloudflare_account_api_token_permission_groups_list" "dns_read" {
  account_id = data.cloudflare_zone.this.account.id
  name       = "DNS Read"
}

resource "cloudflare_account_token" "this" {
  account_id = data.cloudflare_zone.this.account.id
  name       = "cylindric-dns-config"

  policies = [{
    effect = "allow"
    permission_groups = [
      { id = data.cloudflare_account_api_token_permission_groups_list.zone_dns_settings_read.result[0].id },
      { id = data.cloudflare_account_api_token_permission_groups_list.dns_write.result[0].id },
      { id = data.cloudflare_account_api_token_permission_groups_list.dns_read.result[0].id }
    ]
    resources = jsonencode({
      "com.cloudflare.api.account.zone.${data.cloudflare_zone.this.id}" = "*"
    })
  }]

  expires_on = timeadd(timestamp(), "10m")
}
