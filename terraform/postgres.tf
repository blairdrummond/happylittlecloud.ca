resource "digitalocean_database_cluster" "platform_postgres" {
  # Legacy name...
  name       = "keycloak-postgres-cluster"
  engine     = "pg"
  version    = "13"
  size       = "db-s-1vcpu-1gb"
  region     = "tor1"
  node_count = 1
}

resource "digitalocean_database_firewall" "platform_postgres_firewall" {
  cluster_id = digitalocean_database_cluster.platform_postgres.id

  rule {
    type  = "k8s"
    value = digitalocean_kubernetes_cluster.cluster.id
  }
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
