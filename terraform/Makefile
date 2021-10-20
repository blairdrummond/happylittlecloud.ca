ISTIO_VERSION := 1.9.2

.terraform: provider.tf
	terraform init

istio istio-$(ISTIO_VERSION):
	curl -L https://istio.io/downloadIstio | ISTIO_VERSION=$(ISTIO_VERSION) sh -

plan apply: istio-$(ISTIO_VERSION) .terraform
	TF_VAR_do_token=$$(pass digital-ocean-doctl-token) terraform $@
