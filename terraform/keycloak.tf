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
