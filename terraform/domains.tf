# Create a new domain
resource "digitalocean_domain" "happylittlecloud" {
  name       = var.domain_name
}

resource "digitalocean_certificate" "cert" {
  name    = "happylittlecloud-cert"
  type    = "lets_encrypt"
  domains = ["happylittlecloud.ca", "*.happylittlecloud.ca"]

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [digitalocean_domain.happylittlecloud]
}

resource "digitalocean_record" "www" {

  for_each = {
    "root" = "@"
    "www" = "www"
    "wildcard" = "*"
  }

  domain = digitalocean_domain.happylittlecloud.name
  type   = "A"
  name   = each.value
  value  = digitalocean_loadbalancer.happylittlecloud.ip
}


resource "digitalocean_loadbalancer" "happylittlecloud" {
  name        = "happylittlecloud-lb"
  region      = "tor1"

  enable_proxy_protocol = false
  redirect_http_to_https = true


  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"

    target_port     = local.http_node_port
    target_protocol = "http"
  }

  forwarding_rule {
    entry_port     = 443
    entry_protocol = "https"

    target_port     = local.http_node_port
    target_protocol = "http"

    certificate_name = digitalocean_certificate.cert.name
  }
}

## Create a new Load Balancer with TLS termination
#resource "digitalocean_loadbalancer" "happylittlecloud" {
#  name        = "happylittlecloud-lb"
#  region      = "tor1"
#  droplet_tag = "k8s:${digitalocean_kubernetes_cluster.cluster.id}"
#
#  enable_proxy_protocol = true
#  redirect_http_to_https = true
#
#  # droplet_ids = [
#  #   for node in digitalocean_kubernetes_cluster.cluster.node_pool[0].nodes : node.droplet_id
#  # ]
#
#  # Istio ingress gateway health check nodePort
#  healthcheck {
#    port = local.ports.status_port.to
#    protocol = "tcp"
#  }
#
#  forwarding_rule {
#    entry_port     = local.ports.https.from
#    entry_protocol = "https"
#
#    target_port     = local.ports.https.to
#    target_protocol = "http"
#
#    certificate_name = digitalocean_certificate.cert.name
#  }
#
#  forwarding_rule {
#    entry_port     = local.ports.http2.from
#    entry_protocol = "http"
#
#    target_port     = local.ports.http2.to
#    target_protocol = "http"
#  }
#
#  forwarding_rule {
#    entry_port     = local.ports.status_port.from
#    entry_protocol = "tcp"
#
#    target_port     = local.ports.status_port.to
#    target_protocol = "tcp"
#  }
#
#  forwarding_rule {
#    entry_port     = local.ports.tls.from
#    entry_protocol = "tcp"
#
#    target_port     = local.ports.tls.to
#    target_protocol = "tcp"
#  }
#
#  forwarding_rule {
#    entry_port     = local.ports.tcp_istiod.from
#    entry_protocol = "tcp"
#
#    target_port     = local.ports.tcp_istiod.to
#    target_protocol = "tcp"
#  }
#
#}
#
#
