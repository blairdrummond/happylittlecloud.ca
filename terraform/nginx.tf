locals {
  http_node_port = 31982
}

resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  set {
    name = "controller.extraArgs.v"
    value = 2
  }

  set {
    name = "controller.service.annotations.kubernetes\\.digitalocean\\.com/load-balancer-id"
    value = digitalocean_loadbalancer.happylittlecloud.id
  }

  set {
    name = "controller.service.annotations.service\\.kubernetes\\.io/do-loadbalancer-disown"
    value = "\"true\""
  }

  set {
    name = "controller.service.nodePorts.http"
    value = local.http_node_port
  }
}
