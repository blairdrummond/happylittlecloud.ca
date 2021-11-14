
.terraform: provider.tf
	terraform init

plan apply: .terraform
	TF_VAR_do_token=$$(pass digital-ocean-doctl-token) terraform $@

destroy:
	TF_VAR_do_token=$$(pass digital-ocean-doctl-token) terraform apply -destroy
