{
  source: {
    repoURL: std.extVar("ARGOCD_APP_SOURCE_REPO_URL"),
    targetRevision: std.extVar("ARGOCD_APP_SOURCE_TARGET_REVISION"),
    path: std.extVar("ARGOCD_APP_SOURCE_PATH"),
  },
  domain: "happylittlecloud.ca",
  apps: ["nginx"]
}
