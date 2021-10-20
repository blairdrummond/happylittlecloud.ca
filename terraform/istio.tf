resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
  }
}

resource "helm_release" "istio_base" {
  name  = "istio-base"
  chart = "istio-1.9.2/manifests/charts/base"

  timeout = 600
  cleanup_on_fail = true
  force_update    = true
  namespace       = "istio-system"

  depends_on = [digitalocean_kubernetes_cluster.cluster, kubernetes_namespace.istio_system]
}

resource "helm_release" "istiod" {
  name  = "istiod"
  chart = "istio-1.9.2/manifests/charts/istio-control/istio-discovery"

  timeout = 600
  cleanup_on_fail = true
  force_update    = true
  namespace       = "istio-system"

  depends_on = [digitalocean_kubernetes_cluster.cluster, kubernetes_namespace.istio_system, helm_release.istio_base]
}

resource "helm_release" "istio_ingress" {
  name  = "istio-ingress"
  chart = "istio-1.9.2/manifests/charts/gateways/istio-ingress"

  timeout = 600
  cleanup_on_fail = true
  force_update    = true
  namespace       = "istio-system"

  depends_on = [digitalocean_kubernetes_cluster.cluster, kubernetes_namespace.istio_system, helm_release.istiod]

  values = [<<EOF
gateways:
  istio-ingress-gateway:
    loadBalancerIP: ${digitalocean_loadbalancer.happylittlecloud.ip}
    serviceAnnotations:
      kubernetes.digitalocean.com/load-balancer-id: ${digitalocean_loadbalancer.happylittlecloud.id}
      service.kubernetes.io/do-loadbalancer-disown: "true"
EOF
]
}

resource "helm_release" "istio_egress" {
  name  = "istio-egress"
  chart = "istio-1.9.2/manifests/charts/gateways/istio-egress"

  timeout = 600
  cleanup_on_fail = true
  force_update    = true
  namespace       = "istio-system"

  depends_on = [digitalocean_kubernetes_cluster.cluster, kubernetes_namespace.istio_system, helm_release.istiod]
}

