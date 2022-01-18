resource "kubernetes_namespace" "keycloak" {
  metadata {
    name = "keycloak"
  }
}

#resource "random_string" "keycloak_admin" {
#  length           = 32
#  special          = true
#}
#
#resource "kubernetes_secret" "keycloak_admin_secret" {
#  metadata {
#    name = "keycloak-admin-secret"
#    namespace = "keycloak"
#  }
#
#  data = {
#    "username" = "admin"
#    "password" = random_string.keycloak_admin.result
#  }
#}

resource "digitalocean_database_cluster" "platform_postgres" {
  name       = "keycloak-postgres-cluster"
  engine     = "pg"
  version    = "13"
  size       = "db-s-1vcpu-1gb"
  region     = "tor1"
  node_count = 1
}

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

resource "digitalocean_database_db" "keycloak_db" {
  cluster_id = digitalocean_database_cluster.platform_postgres.id
  name       = "keycloak"
}


resource "kubernetes_secret" "keycloak_db_secret" {
  metadata {
    name = "keycloak-db-secret"
    namespace = "keycloak"
  }

  data = {
    "KEYCLOAK_DATABASE_NAME" =  digitalocean_database_db.keycloak_db.name
    "KEYCLOAK_DATABASE_HOST" =  split(":", split("@", digitalocean_database_cluster.platform_postgres.private_uri)[1])[0]
    "KEYCLOAK_DATABASE_PORT" = digitalocean_database_cluster.platform_postgres.port
    "KEYCLOAK_DATABASE_PASSWORD" = digitalocean_database_cluster.platform_postgres.password
    "postgresql-password" = digitalocean_database_cluster.platform_postgres.password
    "KEYCLOAK_DATABASE_USER" = digitalocean_database_cluster.platform_postgres.user
  }
}

resource "kubernetes_service" "keycloak-postgres" {
  metadata {
    name = "keycloak-postgres"
    namespace = "keycloak"
  }
  spec {
    type = "ExternalName"
    external_name = split(":", split("@", digitalocean_database_cluster.platform_postgres.private_uri)[1])[0]
  }
}
