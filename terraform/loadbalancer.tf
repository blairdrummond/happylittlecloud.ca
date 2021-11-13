resource "digitalocean_certificate" "cert" {
  name    = "happylittlecloud-cert"
  type    = "lets_encrypt"
  domains = ["happylittlecloud.ca"]

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [digitalocean_domain.happylittlecloud]
}

locals {
  ports = {
    status_port = {
      "from" = 15021
      "to" = 32436
    }

    http2 = {
      "from" = 80
      "to" = 30450
    }

    # https -> http
    https = {
      from = 443
      # "to" = 30124
      to = 30450
    }

    tcp_istiod = {
      from = 15012
      to = 30374
    }

    tls = {
      from = 15443
      to = 32218
    }
  }
}

# Create a new Load Balancer with TLS termination
resource "digitalocean_loadbalancer" "happylittlecloud" {
  name        = "happylittlecloud-lb"
  region      = "tor1"
  droplet_tag = "k8s:${digitalocean_kubernetes_cluster.cluster.id}"

  enable_proxy_protocol = true
  redirect_http_to_https = true

  # droplet_ids = [
  #   for node in digitalocean_kubernetes_cluster.cluster.node_pool[0].nodes : node.droplet_id
  # ]

  # Istio ingress gateway health check nodePort
  healthcheck {
    port = local.ports.status_port.to
    protocol = "tcp"
  }

  forwarding_rule {
    entry_port     = local.ports.https.from
    entry_protocol = "https"

    target_port     = local.ports.https.to
    target_protocol = "http"

    certificate_name = digitalocean_certificate.cert.name
  }

  forwarding_rule {
    entry_port     = local.ports.http2.from
    entry_protocol = "http"

    target_port     = local.ports.http2.to
    target_protocol = "http"
  }

  forwarding_rule {
    entry_port     = local.ports.status_port.from
    entry_protocol = "tcp"

    target_port     = local.ports.status_port.to
    target_protocol = "tcp"
  }

  forwarding_rule {
    entry_port     = local.ports.tls.from
    entry_protocol = "tcp"

    target_port     = local.ports.tls.to
    target_protocol = "tcp"
  }

  forwarding_rule {
    entry_port     = local.ports.tcp_istiod.from
    entry_protocol = "tcp"

    target_port     = local.ports.tcp_istiod.to
    target_protocol = "tcp"
  }

}

# Create a new domain
resource "digitalocean_domain" "happylittlecloud" {
  name       = var.domain_name
}

# Add an A record to the domain for www.example.com.
resource "digitalocean_record" "www" {
  domain = digitalocean_domain.happylittlecloud.name
  type   = "A"
  name   = "www"
  value  = digitalocean_loadbalancer.happylittlecloud.ip
}
