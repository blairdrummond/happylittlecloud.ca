# Happy Little Cloud cluster

<!--
## Prep for Raspberry Pi 4

- Add some cgroups to `/boot/cmdline.txt` [ref](https://collabnix.com/get-started-with-k3s-a-lightweight-kubernetes-distribution-for-raspberry-pi-cluster/)
- Install [k3s](https://k3s.io/)
-->

## Terraform-init deploys the cluster

There is no fancy GitOps plumbing here yet (avoids secret management). Just `terraform init; terraform apply`.

This will deploy `istio`, `argocd`, and one argocd Application (this repo!)
