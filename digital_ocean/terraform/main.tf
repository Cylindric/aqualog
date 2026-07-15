data "digitalocean_region" "this" {
  slug = "lon1"
}

resource "digitalocean_project" "this" {
  name        = "AquaLog"
  description = "AquaLog Aquatics Monitoring"
  purpose     = "Web Application"
  environment = "Staging"

  resources = [
    digitalocean_kubernetes_cluster.this.urn,
  ]
}

# Create a new container registry
resource "digitalocean_container_registry" "this" {
  name                   = "aqualog"
  subscription_tier_slug = "starter"
}

resource "digitalocean_container_registry_docker_credentials" "this" {
  registry_name = digitalocean_container_registry.this.name
}

# Create a new Kubernetes cluster
resource "digitalocean_kubernetes_cluster" "this" {
  name                 = "aqualog"
  region               = data.digitalocean_region.this.slug
  version              = "1.36.0-do.2"
  ha                   = false
  registry_integration = true

  node_pool {
    name       = "worker-pool"
    size       = "s-1vcpu-2gb"
    node_count = 1
    labels     = {}
    max_nodes  = 0
    min_nodes  = 0
    tags       = []
  }

  tags = []

  amd_gpu_device_plugin {
    enabled = false
  }

  amd_gpu_device_metrics_exporter_plugin {
    enabled = false
  }

  coredns_autoscaler {
    enabled = true
  }

  maintenance_policy {
    day        = "any"
    start_time = "13:00"
  }

  nvidia_gpu_device_plugin {
    enabled = false
  }
  rdma_shared_device_plugin {
    enabled = false
  }

  routing_agent {
    enabled = false
  }

  depends_on = [
    digitalocean_container_registry.this,
  ]
}
