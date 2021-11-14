resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
  }
}

resource "kubectl_manifest" "istio_application" {
  yaml_body = <<YAML
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: istio
  namespace: argocd
spec:
  project: default
  destination:
    namespace: istio-system
    server: https://kubernetes.default.svc
  source:
    repoURL: https://github.com/${var.github_username}/${var.github_repo}.git
    targetRevision: main
    path: istio
  ignoreDifferences:
  - group: admissionregistration.k8s.io
    kind: MutatingWebhookConfiguration
    jsonPointers:
    - /webhooks/0/clientConfig/caBundle
  - group: admissionregistration.k8s.io
    kind: ValidatingWebhookConfiguration
    jsonPointers:
    - /webhooks/0/clientConfig/caBundle
    - /webhooks/0/failurePolicy
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
YAML

  depends_on = [helm_release.argocd]
}

# Wait for the ArgoCD CRDs to be defined.
resource "time_sleep" "wait_for_istio" {
  depends_on = [kubectl_manifest.istio_application]
  create_duration = "10s"
}
