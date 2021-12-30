# $ doctl kubernetes options versions
resource "digitalocean_kubernetes_cluster" "cluster" {
  name    = var.cluster_name
  region  = "tor1"
  version = "1.21.5-do.0"

  node_pool {
    name       = "autoscale-worker-pool"
    # doctl kubernetes options sizes
    size       = "s-2vcpu-4gb"
    auto_scale = true
    min_nodes  = 1
    max_nodes  = 3
  }
}

# resource "digitalocean_kubernetes_cluster" "dev_cluster" {
#   name    = format("%s-dev", var.cluster_name)
#   region  = "tor1"
#   version = "1.21.3-do.0"
#
#   node_pool {
#     name       = "autoscale-worker-pool"
#     # doctl kubernetes options sizes
#     size       = "s-4vcpu-8gb"
#     auto_scale = true
#     min_nodes  = 1
#     max_nodes  = 3
#   }
# }
