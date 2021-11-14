resource "kubernetes_namespace" "web_system" {
  metadata {
    name = "web-system"
    labels = {
      istio-injection = "enabled"
    }
  }
}
