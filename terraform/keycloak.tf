resource "kubernetes_namespace" "keycloak" {
  metadata {
    name = "keycloak"
  }
}

resource "random_string" "keycloak_admin" {
  length           = 32
  special          = true
}

resource "kubernetes_secret" "keycloak_admin_secret" {
  metadata {
    name = "keycloak-admin-secret"
    namespace = "keycloak"
  }

  data = {
    "username" = "admin"
    "password" = random_string.keycloak_admin.result
  }
}

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
    "POSTGRES_DATABASE" =  digitalocean_database_db.keycloak_db.name
    "POSTGRES_EXTERNAL_ADDRESS" =  digitalocean_database_cluster.platform_postgres.private_uri
    "POSTGRES_EXTERNAL_PORT" = digitalocean_database_cluster.platform_postgres.port
    "POSTGRES_PASSWORD" = digitalocean_database_cluster.platform_postgres.password
    "POSTGRES_USERNAME" = digitalocean_database_cluster.platform_postgres.user
  }
}
