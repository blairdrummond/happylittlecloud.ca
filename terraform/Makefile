
.terraform: provider.tf
	terraform init

refresh plan apply: .terraform
	TF_VAR_do_token=$$(pass digital-ocean-doctl-token) \
	TF_VAR_spaces_key=$$(pass digital-ocean-spaces-key) \
	TF_VAR_spaces_secret=$$(pass digital-ocean-spaces-secret) \
	TF_VAR_spaces_secret=$$(pass digital-ocean-spaces-secret) \
	TF_VAR_registry_read_token=$$(pass dockerhub-k8s-read) \
	TF_VAR_registry_write_token=$$(pass dockerhub-k8s-write) \
		terraform $@

destroy:
	TF_VAR_do_token=$$(pass digital-ocean-doctl-token) terraform apply -destroy
