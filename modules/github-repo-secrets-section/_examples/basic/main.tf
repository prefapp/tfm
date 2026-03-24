module "repo_secrets" {
  source = "git::https://github.com/prefapp/tfm.git//modules/github-repo-secrets-section"

  config = var.config   # Terraform automatically loads terraform.tfvars.json
}
