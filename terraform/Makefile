
modules:
	rm -rf .terraform/modules/
	terraform init

.terraform: provider.tf
	terraform init

refresh plan apply: .terraform
	TF_VAR_do_token=$$(pass digital-ocean-doctl-token) \
	TF_VAR_spaces_key=$$(pass digital-ocean-spaces-key) \
	TF_VAR_spaces_secret=$$(pass digital-ocean-spaces-secret) \
	TF_VAR_registry_read_token=$$(pass dockerhub-k8s-read) \
	TF_VAR_registry_write_token=$$(pass dockerhub-k8s-write) \
	TF_VAR_github_token=$$(pass github-api-read) \
	TF_VAR_github_argo_client_id=$$(pass github-argo-client-id) \
	TF_VAR_github_argo_client_secret=$$(pass github-argo-client-secret) \
		terraform $@

destroy:
	TF_VAR_do_token=$$(pass digital-ocean-doctl-token) terraform apply -destroy


shell: .terraform
	TF_VAR_do_token=$$(pass digital-ocean-doctl-token) \
	TF_VAR_spaces_key=$$(pass digital-ocean-spaces-key) \
	TF_VAR_spaces_secret=$$(pass digital-ocean-spaces-secret) \
	TF_VAR_registry_read_token=$$(pass dockerhub-k8s-read) \
	TF_VAR_registry_write_token=$$(pass dockerhub-k8s-write) \
	TF_VAR_github_token=$$(pass github-api-read) \
	TF_VAR_github_argo_client_id=$$(pass github-argo-client-id) \
	TF_VAR_github_argo_client_secret=$$(pass github-argo-client-secret) \
		zsh
