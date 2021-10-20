resource "digitalocean_certificate" "cert" {
  name    = "happylittlecloud-cert"
  type    = "lets_encrypt"
  domains = ["happylittlecloud.ca"]

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [digitalocean_domain.happylittlecloud]
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
    port = 30545
    protocol = "tcp"
  }

  forwarding_rule {
    entry_port     = 443
    entry_protocol = "https"

    target_port     = 80
    target_protocol = "http"

    certificate_name = digitalocean_certificate.cert.name
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
