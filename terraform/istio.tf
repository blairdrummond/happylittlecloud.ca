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
  istio-ingressgateway:
    loadBalancerIP: ${digitalocean_loadbalancer.happylittlecloud.ip}
    serviceAnnotations:
      kubernetes.digitalocean.com/load-balancer-id: ${digitalocean_loadbalancer.happylittlecloud.id}
      service.kubernetes.io/do-loadbalancer-disown: "true"
    ports:
    ## You can add custom gateway ports in user values overrides, but it must include those ports since helm replaces.
    # Note that AWS ELB will by default perform health checks on the first port
    # on this list. Setting this to the health check port will ensure that health
    # checks always work. https://github.com/istio/istio/issues/12503
    - port: 15021
      targetPort: 15021
      nodePort: 32436
      name: status-port
      protocol: TCP
    - port: 80
      targetPort: 8080
      nodePort: 30450
      name: http2
      protocol: TCP
    - port: 443
      targetPort: 8443
      nodePort: 30124
      name: https
      protocol: TCP
    - port: 15012
      targetPort: 15012
      nodePort: 30374
      name: tcp-istiod
      protocol: TCP
    # This is the port where sni routing happens
    - port: 15443
      targetPort: 15443
      nodePort: 32218
      name: tls
      protocol: TCP
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

