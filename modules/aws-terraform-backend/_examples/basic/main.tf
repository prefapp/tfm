provider "aws" {
  region = "eu-west-1"
}

module "terraform_backend" {
  source = "../../"

  tfstate_bucket_name   = "example-terraform-state-bucket"
  tfstate_object_prefix = "envs/prod/terraform.tfstate"
  locks_table_name      = "example-terraform-locks"

  aws_account_id                               = "123456789012"
  cloudformation_admin_role_for_client_account = "tf-backend-admin"
}
