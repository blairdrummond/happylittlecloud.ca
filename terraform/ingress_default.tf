#locals {
#  http_node_port = 31982
#}
#
## Create a new domain
#resource "digitalocean_domain" "happylittlecloud" {
#  name       = var.domain_name
#}
#
#resource "digitalocean_certificate" "cert" {
#  name    = "happylittlecloud-cert"
#  type    = "lets_encrypt"
#  domains = ["happylittlecloud.ca", "*.happylittlecloud.ca"]
#
#  lifecycle {
#    create_before_destroy = true
#  }
#
#  depends_on = [digitalocean_domain.happylittlecloud]
#}
#
#resource "digitalocean_record" "www" {
#
#  for_each = {
#    "root" = "@"
#    "www" = "www"
#    "wildcard" = "*"
#  }
#
#  domain = digitalocean_domain.happylittlecloud.name
#  type   = "A"
#  name   = each.value
#  value  = digitalocean_loadbalancer.happylittlecloud.ip
#}
#
#
#resource "digitalocean_loadbalancer" "happylittlecloud" {
#  name        = "happylittlecloud-lb"
#  region      = "tor1"
#
#  enable_proxy_protocol = false
#  redirect_http_to_https = true
#
#
#  forwarding_rule {
#    entry_port     = 80
#    entry_protocol = "http"
#
#    target_port     = local.http_node_port
#    target_protocol = "http"
#  }
#
#  forwarding_rule {
#    entry_port     = 443
#    entry_protocol = "https"
#
#    target_port     = local.http_node_port
#    target_protocol = "http"
#
#    certificate_name = digitalocean_certificate.cert.name
#  }
#}
#
#resource "helm_release" "ingress_nginx" {
#  name       = "ingress-nginx"
#  repository = "https://kubernetes.github.io/ingress-nginx"
#  chart      = "ingress-nginx"
#
#  set {
#    name = "controller.extraArgs.v"
#    value = 2
#  }
#
#  set {
#    name = "controller.service.annotations.kubernetes\\.digitalocean\\.com/load-balancer-id"
#    value = digitalocean_loadbalancer.happylittlecloud.id
#  }
#
#  set {
#    name = "controller.service.annotations.service\\.kubernetes\\.io/do-loadbalancer-disown"
#    value = "\"true\""
#  }
#
#  set {
#    name = "controller.service.nodePorts.http"
#    value = local.http_node_port
#  }
#}
