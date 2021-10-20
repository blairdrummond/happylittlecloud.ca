local vars = import 'vars.libsonnet';

[
{
  "apiVersion": "argoproj.io/v1alpha1",
  "kind": "Application",
  "metadata": {
    "name": app,
    "namespace": "argocd"
  },
  "spec": {
    "project": "default",
    "destination": {
      "namespace": "default",
      "server": "https://kubernetes.default.svc"
    },
    "source": vars.source + { path: vars.source.path + "/" + app },
    "syncPolicy": {
      "automated": {
        "prune": true,
        "selfHeal": true
      }
    }
  }
} for app in vars.apps
]
