# S3-only Terraform backend example. Terraform 1.11+ can use S3 lockfiles.

module "terraform_backend" {
  source = "../.."

  tfstate_bucket_name                          = "example-tfstate-bucket"
  tfstate_object_prefix                        = "platform/terraform.tfstate"
  aws_account_id                               = "123456789012"
  cloudformation_admin_role_for_client_account = "TerraformClientAdmin"

  tags = {
    Environment = "development"
    ManagedBy   = "Terraform"
  }
}
