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



# For Gitea
resource "digitalocean_spaces_bucket" "happylittlecloud_gitea" {
  name   = "happylittlecloud-gitea"
  region = "nyc3"
}

resource "kubernetes_secret" "spaces_secret_gitea" {
  metadata {
    name = "spaces-secret"
    namespace = "gitea"
  }

  data = {
    "storage" = <<EOF
STORAGE_TYPE=my_minio
EOF
    "storage.my_minio" = <<EOF
   STORAGE_TYPE=minio
   MINIO_ENDPOINT=${digitalocean_spaces_bucket.happylittlecloud_gitea.region}.digitaloceanspaces.com
   MINIO_ACCESS_KEY_ID=${var.spaces_key}
   MINIO_SECRET_ACCESS_KEY=${var.spaces_secret}
   MINIO_BUCKET=${digitalocean_spaces_bucket.happylittlecloud_gitea.name}
   MINIO_LOCATION=us-east-1
   MINIO_USE_SSL=true
EOF
  }
}
