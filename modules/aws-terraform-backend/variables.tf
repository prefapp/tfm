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

variable "main_role_name" {
  description = "Terraform backend access role name (main)"
  type        = string
  default     = "terraform-backend-access-role"
}

variable "aux_role_name" {
  description = "Terraform backend access role (auxiliary)"
  type        = string
  default     = "terraform-backend-aux-access-role"
}


variable "backend_extra_roles" {
  description = "Additional roles to add to the Terraform backend access role"
  type        = list(string)
  default     = []
}

variable "aws_client_account_id" {
  description = "AWS Account ID that will assume the role that allows access to the S3 bucket and the dynamodb table"
  type        = string
}

variable "create_aux_role" {
  description = "Decide whether to generate a specific auxiliary role for the client account"
  type        = bool
  default     = false
}

variable "external_main_role" {
  description = "Role name that will assume the role to access the S3 bucket and the dynamodb table with admin access"
  type        = string
}

variable "external_aux_role" {
  description = "Role name that will assume the role to access the S3 bucket and the dynamodb table with read-only access"
  type        = string
  default     = ""
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
