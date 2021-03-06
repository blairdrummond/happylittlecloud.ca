resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
    # labels = {
    #   "istio-injection" = "enabled"
    # }
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "3.26.8"

  timeout = 600
  cleanup_on_fail = true
  force_update    = true
  namespace       = "argocd"

  depends_on = [digitalocean_kubernetes_cluster.cluster, kubernetes_namespace.argocd]

  values = [<<EOF
server:
  config:
    kustomize.buildOptions: "--load-restrictor LoadRestrictionsNone --enable-helm"
EOF
  ]
}

resource "helm_release" "argocd_applicationset" {
  name       = "argocd-applicationset"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-applicationset"
  version    = "1.6.0"

  timeout = 600
  cleanup_on_fail = true
  force_update    = true
  namespace       = "argocd"

  depends_on = [helm_release.argocd]
}



# # Dev Cluster
# resource "kubernetes_secret" "" {
#   metadata {
#     name = "docker-cfg"
#   }
#
#   data = {
#     ".dockerconfigjson" = "${file("${path.module}/.docker/config.json")}"
#   }
#
#   type = "kubernetes.io/dockerconfigjson"
# }



resource "kubectl_manifest" "argocd_projects" {
  yaml_body = <<YAML
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: projects
  namespace: argocd
spec:
  project: default
  destination:
    namespace: argocd
    server: https://kubernetes.default.svc
  source:
    repoURL: https://github.com/${var.github_username}/${var.github_repo}.git
    targetRevision: main
    path: projects
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
YAML

  depends_on = [helm_release.argocd]
}
