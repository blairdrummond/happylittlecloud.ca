resource "kubernetes_namespace" "argo_events" {
  metadata {
    name = "argo-events"
  }
}
