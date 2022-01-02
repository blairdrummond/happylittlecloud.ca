resource "kubernetes_namespace" "argo" {
  metadata {
    name = "argo"
  }
}

# READ Token
resource "kubernetes_secret" "github_argo_oauth" {
  metadata {
    name = "github-oauth"
    namespace = "argo"
  }

  data = {
    "client-id" = var.github_argo_client_id
    "client-secret" = var.github_argo_client_secret
  }
}


resource "kubernetes_config_map" "workflow_controller" {
  metadata {
    name = "workflow-controller-configmap"
    namespace = "argo"
  }

  data = {
    "containerRuntimeExecutor" = "pns"
    "artifactRepository" = <<EOF
    archiveLogs: true
    s3:
      endpoint: ${digitalocean_spaces_bucket.happylittlecloud_private.region}.digitaloceanspaces.com
      bucket: ${digitalocean_spaces_bucket.happylittlecloud_private.name}
      region: us-west-2
      insecure: false
      # keyFormat is a format pattern to define how artifacts will be organized in a bucket.
      # It can reference workflow metadata variables such as workflow.namespace, workflow.name,
      # pod.name. Can also use strftime formating of workflow.creationTimestamp so that workflow
      # artifacts can be organized by date. If omitted, will use `{{workflow.name}}/{{pod.name}}`,
      # which has potential for have collisions.
      # The following example pattern organizes workflow artifacts under a "my-artifacts" sub dir,
      # then sub dirs for year, month, date and finally workflow name and pod.
      # e.g.: my-artifacts/2018/08/23/my-workflow-abc123/my-workflow-abc123-1234567890
      keyFormat: "argo-workflows\
        /{{workflow.creationTimestamp.Y}}\
        /{{workflow.creationTimestamp.m}}\
        /{{workflow.creationTimestamp.d}}\
        /{{workflow.name}}\
        /{{pod.name}}"
      accessKeySecret:
        name: spaces-secret
        key: key
      secretKeySecret:
        name: spaces-secret
        key: secret
EOF

  }
}
