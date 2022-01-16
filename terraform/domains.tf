# Create a new domain
resource "digitalocean_domain" "happylittlecloud" {
  name       = var.domain_name
}

#data "digitalocean_loadbalancer" "example" {
#  name = "app"
#}
