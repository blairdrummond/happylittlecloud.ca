resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
    # labels = {
    #   "istio-injection" = "enabled"
    # }
  }
}

data "http" "argocd_manifest" {
  url = "https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
}

data "kubectl_file_documents" "manifests" {
    content = data.http.argocd_manifest.body
}

resource "kubectl_manifest" "argocd" {
  override_namespace = "argocd"

  count     = length(data.kubectl_file_documents.manifests.documents)
  yaml_body = element(data.kubectl_file_documents.manifests.documents, count.index)

  depends_on = [kubernetes_namespace.argocd]
}

# Wait for the ArgoCD CRDs to be defined.
resource "time_sleep" "wait_1_minute" {
  depends_on = [kubectl_manifest.argocd]
  create_duration = "61s"
}

resource "kubectl_manifest" "root_application" {
  yaml_body = <<YAML
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${var.github_repo}
  namespace: argocd
spec:
  project: default
  destination:
    namespace: default
    server: https://kubernetes.default.svc
  source:
    repoURL: https://github.com/${var.github_username}/${var.github_repo}.git
    targetRevision: main
    path: manifests
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
YAML

  depends_on = [kubectl_manifest.argocd]
}
