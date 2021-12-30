#resource "kubernetes_namespace" "shipwright_build" {
#  metadata {
#    name = "shipwright-build"
#  }
#}


resource "kubernetes_secret" "docker_registry_read" {
  for_each = toset([
    "shipwright-build",
    "web-system"
  ])

  metadata {
    name = "image-pull-secret"
    namespace = each.key
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${var.registry_server}" = {
          auth = "${base64encode("${var.registry_username}:${var.registry_read_token}")}"
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"
}


resource "kubernetes_secret" "docker_registry_write" {
  metadata {
    name = "registry-write"
    namespace = "shipwright-build"
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${var.registry_server}" = {
          auth = "${base64encode("${var.registry_username}:${var.registry_write_token}")}"
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"
}




# Create a new container registry
# resource "digitalocean_container_registry" "registry" {
#   name                   = "happylittlecloud"
#   subscription_tier_slug = "basic"
# }
#
# resource "digitalocean_container_registry_docker_credentials" "happylittlecloud" {
#   registry_name = "happylittlecloud"
#   write = true
#
#   depends_on = [digitalocean_container_registry.registry]
# }
#
# resource "digitalocean_container_registry_docker_credentials" "happylittlecloud_read" {
#   registry_name = "happylittlecloud"
#
#   depends_on = [digitalocean_container_registry.registry]
# }
#
# resource "kubernetes_secret" "docker_registry" {
#   for_each = toset([
#     "shipwright-build",
#     "web-system"
#   ])
#
#   metadata {
#     name = "docker-registry"
#     namespace = each.key
#
#     annotations = {
#       "build.shipwright.io/referenced.secret" = "true"
#     }
#   }
#
#    data = {
#     ".dockerconfigjson" = digitalocean_container_registry_docker_credentials.happylittlecloud.docker_credentials
#   }
#
#   type = "kubernetes.io/dockerconfigjson"
# }
#
# resource "kubernetes_secret" "docker_registry_read" {
#   for_each = toset([
#     "shipwright-build",
#     "web-system"
#   ])
#
#   metadata {
#     name = "image-pull-secret"
#     namespace = each.key
#   }
#
#    data = {
#     ".dockerconfigjson" = digitalocean_container_registry_docker_credentials.happylittlecloud_read.docker_credentials
#   }
#
#   type = "kubernetes.io/dockerconfigjson"
# }
