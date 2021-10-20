# Set the variable value in *.tfvars file
# or using -var="do_token=..." CLI option
variable "do_token" {}
variable "github_username" {
  description = "Your github username"
}
variable "github_repo" {
  description = "Your github repo"
}
variable "cluster_name" {
  description = "A unique name for your cluster"
}

variable "domain_name" {
  description = "The Domain (e.g. happylittlecloud.ca)"
}
