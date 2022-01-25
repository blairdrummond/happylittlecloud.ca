resource "kubernetes_namespace" "minio" {
  metadata {
    name = "minio"
  }
}

module "minio_gateway" {

  source = "git::https://github.com/blairdrummond/minio-gateway-opa.git//terraform/digitalocean/"

  spaces_bucket = "happylittlecloud-minio"
  spaces_key    = var.spaces_key
  spaces_secret = var.spaces_secret
  namespace     = "minio"

  depends_on = [kubernetes_namespace.minio]
}


