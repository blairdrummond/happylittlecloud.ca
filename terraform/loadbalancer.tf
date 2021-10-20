resource "digitalocean_certificate" "cert" {
  name    = "happylittlecloud-cert"
  type    = "lets_encrypt"
  domains = ["happylittlecloud.ca"]

  lifecycle {
    create_before_destroy = true
  }
}

# Create a new Load Balancer with TLS termination
resource "digitalocean_loadbalancer" "happylittlecloud" {
  name        = "happylittlecloud-lb"
  region      = "nyc3"
  droplet_tag = "happylittlecloud"

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
  ip_address = digitalocean_loadbalancer.happylittlecloud.ip
}

# Add an A record to the domain for www.example.com.
resource "digitalocean_record" "www" {
  domain = digitalocean_domain.happylittlecloud.name
  type   = "A"
  name   = "www"
  value  = digitalocean_loadbalancer.happylittlecloud.ip
}
