resource "kubernetes_namespace" "gitea" {
  metadata {
    name = "gitea"
  }
}

resource "random_string" "gitea_admin" {
  length           = 32
  special          = true
}

# READ Token
resource "kubernetes_secret" "gitea_admin_secret" {
  metadata {
    name = "gitea-admin-secret"
    namespace = "gitea"
  }

  data = {
    "username" = "blair"
    "password" = random_string.gitea_admin.result
    "email" = "blairdrummond@protonmail.com"
  }
}




resource "digitalocean_database_db" "gitea_db" {
  cluster_id = digitalocean_database_cluster.platform_postgres.id
  name       = "gitea"
}


resource "kubernetes_secret" "gitea_db_secret" {
  metadata {
    name = "gitea-db-secret"
    namespace = "gitea"
  }

  data = {
    "database" = <<EOF
  DB_TYPE=postgres
  SSL_MODE=require
  NAME=${digitalocean_database_db.keycloak_db.name}
  HOST=${split(":", split("@", digitalocean_database_cluster.platform_postgres.private_uri)[1])[0]}:${digitalocean_database_cluster.platform_postgres.port}
  USER=${digitalocean_database_cluster.platform_postgres.user}
  PASSWD=${digitalocean_database_cluster.platform_postgres.password}
EOF
  }
}

resource "kubernetes_service" "gitea-postgres" {
  metadata {
    name = "gitea-postgres"
    namespace = "gitea"
  }
  spec {
    type = "ExternalName"
    external_name = split(":", split("@", digitalocean_database_cluster.platform_postgres.private_uri)[1])[0]
  }
}
