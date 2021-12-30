resource "digitalocean_spaces_bucket" "happylittlecloud" {
  name   = "s3.happylittlecloud.ca"
  region = "nyc3"
  acl    = "public-read"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
}

resource "digitalocean_certificate" "minio_cert" {
  name    = "happylittlecloud-minio-cert"
  type    = "lets_encrypt"
  domains = [digitalocean_spaces_bucket.happylittlecloud.name]

  lifecycle {
    create_before_destroy = true
  }
}
#
## Add a CDN endpoint with a custom sub-domain to the Spaces Bucket
resource "digitalocean_cdn" "happylittlecloud" {
  origin           = digitalocean_spaces_bucket.happylittlecloud.bucket_domain_name
  custom_domain    = digitalocean_spaces_bucket.happylittlecloud.name
  certificate_name = digitalocean_certificate.minio_cert.name
  ttl              = 604800
}


resource "kubernetes_secret" "do_token" {
  metadata {
    name = "do-token"
    namespace = "default"
  }

  data = {
    "cdn-id" = digitalocean_cdn.happylittlecloud.id
    "token"  = var.do_token
  }
}

resource "kubernetes_secret" "spaces_secret" {
  metadata {
    name = "spaces-secret"
    namespace = "default"
  }

  data = {
    "url"    = "https://${digitalocean_spaces_bucket.happylittlecloud.region}.digitaloceanspaces.com"
    "bucket" = digitalocean_spaces_bucket.happylittlecloud.name
    "key"    = var.spaces_key
    "secret" = var.spaces_secret
  }
}


# For Argo and such
resource "digitalocean_spaces_bucket" "happylittlecloud_private" {
  name   = "happylittlecloud-private"
  region = "nyc3"
}

