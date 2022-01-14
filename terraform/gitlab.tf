# resource "kubernetes_namespace" "gitlab" {
#   metadata {
#     name = "gitlab"
#   }
# }
# resource "random_string" "gitlab_minio_secret" {
#   length           = 32
#   special          = false
# }
#
# resource "kubernetes_secret" "gitlab_minio_secret" {
#   metadata {
#     name = "gitlab-minio-secret"
#     namespace = "gitlab"
#   }
#
#   data = {
#     "accessKey" = "minioadmin"
#     "secretKey" = random_string.gitlab_minio_secret.result
#   }
# }

#resource "random_string" "gitea_admin" {
#  length           = 32
#  special          = true
#}
#
## READ Token
#resource "kubernetes_secret" "gitea_admin_secret" {
#  metadata {
#    name = "gitea-admin-secret"
#    namespace = "gitea"
#  }
#
#  data = {
#    "username" = "blair"
#    "password" = random_string.gitea_admin.result
#    "email" = "blairdrummond@protonmail.com"
#  }
#}

#  resource "digitalocean_database_cluster" "gitlab_postgres" {
#   name       = "gitlab-postgres-cluster"
#   engine     = "pg"
#   version    = "13"
#   size       = "db-s-1vcpu-1gb"
#   region     = "tor1"
#   node_count = 1
# }
#
# resource "digitalocean_database_cluster" "redis-example" {
#   name       = "gitlab-redis-cluster"
#   engine     = "redis"
#   version    = "6"
#   size       = "db-s-1vcpu-1gb"
#   region     = "tor1"
#   node_count = 1
# }

# In addition to the above arguments, the following attributes are exported:
#
#     id - The ID of the database cluster.
#     urn - The uniform resource name of the database cluster.
#     host - Database cluster's hostname.
#     private_host - Same as host, but only accessible from resources within the account and in the same region.
#     port - Network port that the database cluster is listening on.
#     uri - The full URI for connecting to the database cluster.
#     private_uri - Same as uri, but only accessible from resources within the account and in the same region.
#     database - Name of the cluster's default database.
#     user - Username for the cluster's default user.
#     password - Password for the cluster's default user.
