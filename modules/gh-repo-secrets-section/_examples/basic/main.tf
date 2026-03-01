module "repo_secrets" {
  source = "git::https://github.com/prefapp/tfm.git//modules/github-repository-secrets"

  config = var.config   # Terraform automatically loads terraform.tfvars.json
}
