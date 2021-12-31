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

variable "spaces_key" {
  description = "Digital Ocean Spaces Key"
}

variable "spaces_secret" {
  description = "Digital Ocean Spaces Secret"
}

variable "registry_server" {
  description = "Registry server"
}
variable "registry_username" {
  description = "Registry Username"
}
variable "registry_read_token" {
  description = "Registry read token"
}
variable "registry_write_token" {
  description = "Registry write token"
}

variable "github_token" {
  description = "Github Read Token"
}
