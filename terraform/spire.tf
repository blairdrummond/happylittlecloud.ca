resource "kubernetes_namespace" "spire" {
  metadata {
    name = "spire"
  }
}
