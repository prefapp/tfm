# DynamoDB locking example for consumers that require a locks table.

module "terraform_backend" {
  source = "../.."

  tfstate_bucket_name                          = "example-tfstate-bucket"
  tfstate_object_prefix                        = "platform/terraform.tfstate"
  locks_table_name                             = "example-terraform-locks"
  aws_account_id                               = "123456789012"
  cloudformation_admin_role_for_client_account = "TerraformClientAdmin"

  tags = {
    Environment = "development"
    ManagedBy   = "Terraform"
  }
}
