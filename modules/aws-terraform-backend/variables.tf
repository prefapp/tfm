variable "tfstate_bucket_name" {
  description = "Name of the S3 Bucket used for storing the Terraform state for the workspaces"
  type        = string
}

variable "tfstate_object_prefix" {
  description = "Prefix to the S3 bucket objects"
  type        = string
}

variable "locks_table_name" {
  description = "Name of the locks DynamoDB table"
  type        = string
  default     = null
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

variable "tfstate_force_destroy" {
  description = "Allow destroying the Terraform state bucket even if it contains objects"
  type        = bool
  default     = false
}

variable "tfstate_enable_versioning" {
  description = "Enable versioning on the bucket"
  type        = bool
  default     = true
}

variable "tfbackend_access_role_name" {
  description = "Terraform backend access role"
  type        = string
  default     = "terraform-backend-access-role"
}


variable "backend_extra_roles" {
  description = "Additional roles to add to the Terraform backend access role"
  type        = list(string)
  default     = []
}

variable "aws_account_id" {
  description = "AWS Account ID that will assume the role to access the S3 bucket and the dynamodb table"
  type        = string
}

variable "cloudformation_admin_role_for_client_account" {
  description = "Role name that will assume the role to access the S3 bucket and the dynamodb table"
  type        = string
}

variable "generate_cloudformation_role_for_client_account" {
  description = "Decide whether to generate a cloudformation stack with a iam role to access the account with administrative privileges"
  type        = bool
  default     = true
}

variable "upload_cloudformation_role" {
  description = "Decide whether to upload to S3 the cloudformation stack"
  type        = bool
  default     = true
}

variable "s3_bucket_cloudformation_role" {
  description = "Name of the S3 bucket where the cloudformation template will be uploaded"
  type        = string
  default     = ""
}

variable "s3_bucket_cloudformation_role_key" {
  type        = string
  default     = "cloudformation/rendered-template.yaml"
  description = "Key to use when uploading the template to S3"
}

variable "create_github_iam" {
  description = "Create IAM resources for GitHub"
  type        = bool
  default     = false
}

variable "github_repository" {
  description = "Name of the GitHub repository to access the backend"
  type        = string
  default     = ""
}
