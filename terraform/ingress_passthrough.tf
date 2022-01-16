#locals {
#  passthrough_https_node_port = 31443
#}
#
##resource "kubernetes_namespace" "nginx_passthrough" {
##  metadata {
##    name = "nginx-passthrough"
##  }
##}
#
#resource "digitalocean_record" "passthrough" {
#
#  # secure (tls passthrough) subdomains
#  for_each = {
#    "login" = "login"
#  }
#
#  domain = digitalocean_domain.happylittlecloud.name
#  type   = "A"
#  name   = each.value
#  value  = digitalocean_loadbalancer.secure_happylittlecloud.ip
#}
#
#
#resource "digitalocean_loadbalancer" "secure_happylittlecloud" {
#  name        = "happylittlecloud-lb-secure"
#  region      = "tor1"
#
#  enable_proxy_protocol = false
#
#  forwarding_rule {
#    entry_port     = 443
#    entry_protocol = "https"
#
#    target_port     = local.passthrough_https_node_port
#    target_protocol = "https"
#
#    tls_passthrough = true
#  }
#}
#
#resource "helm_release" "secure_ingress_nginx" {
#  name       = "passthrough-ingress-nginx"
#  repository = "https://kubernetes.github.io/ingress-nginx"
#  chart      = "ingress-nginx"
#
#  # Only install the CRDs once
#  skip_crds = true
#  depends_on = [helm_release.ingress_nginx]
#
#  # Use a different ingressClass name
#  set {
#    name = "controller.ingressClassResource.name"
#    value = "nginx-tls"
#  }
#
#  set {
#    name = "controller.extraArgs.v"
#    value = 2
#  }
#
#  set {
#    name = "controller.service.annotations.kubernetes\\.digitalocean\\.com/load-balancer-id"
#    value = digitalocean_loadbalancer.secure_happylittlecloud.id
#  }
#
#  set {
#    name = "controller.service.annotations.service\\.kubernetes\\.io/do-loadbalancer-disown"
#    value = "\"true\""
#  }
#
#  set {
#    name = "controller.service.enableHttp"
#    value = false
#  }
#
#  set {
#    name = "controller.service.nodePorts.https"
#    value = local.passthrough_https_node_port
#  }
#}
