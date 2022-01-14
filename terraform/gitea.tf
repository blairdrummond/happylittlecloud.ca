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
