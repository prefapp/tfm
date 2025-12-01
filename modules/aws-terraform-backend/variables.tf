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

variable "aws_client_account_id" {
  description = "AWS client account ID where the CloudFormation roles will be created"
  type        = string
}

# Simplified CloudFormation configuration
variable "generate_cloudformation_roles" {
  description = "Generate CloudFormation template with IAM roles for external account access"
  type        = bool
  default     = true
}

variable "upload_cloudformation_template" {
  description = "Upload the CloudFormation template to S3"
  type        = bool
  default     = true
}

variable "cloudformation_s3_bucket" {
  description = "S3 bucket where the CloudFormation template will be uploaded"
  type        = string
  default     = ""
}

variable "cloudformation_s3_key" {
  description = "S3 key for the CloudFormation template"
  type        = string
  default     = "cloudformation/terraform-backend-roles.yaml"
}

# Simplified roles configuration
variable "roles" {
  description = <<-EOT
    Configuration for IAM roles in the backend account.
    Each role can assume a corresponding role in the client account via CloudFormation.

    Structure:
    - admin: Full admin access role (required)
      - name: Role name in backend account
      - external_role_name: Role name to create in client account via CloudFormation
      - aws_account_id: Backend account ID (defaults to current account)
    - readwrite: Read-write S3 access role (optional)
      - name: Role name in backend account
      - external_role_name: Role name to create in client account via CloudFormation
      - aws_account_id: Backend account ID (defaults to current account)
  EOT

  type = object({
    admin = object({
      name               = string
      external_role_name = string
      aws_account_id     = optional(string)
    })
    readwrite = optional(object({
      name               = string
      external_role_name = string
      aws_account_id     = optional(string)
    }))
  })
}

# Simplified OIDC configuration - applies to all roles
variable "oidc_provider_url" {
  description = "OIDC provider URL (e.g., token.actions.githubusercontent.com). If not provided, roles won't have OIDC trust"
  type        = string
  default     = ""
}

variable "oidc_audiences" {
  description = "List of allowed OIDC audiences (e.g., ['sts.amazonaws.com'])"
  type        = list(string)
  default     = ["sts.amazonaws.com"]
}

variable "oidc_subjects" {
  description = <<-EOT
    Map of OIDC subjects for each role. Supports both exact matches and wildcards.
    Example:
    {
      admin = {
        exact    = ["repo:myorg/myrepo:ref:refs/heads/main"]
        wildcard = ["repo:myorg/myrepo:*"]
      }
      readwrite = {
        exact    = ["repo:myorg/myrepo:ref:refs/heads/develop"]
        wildcard = ["repo:myorg/*:pull_request"]
      }
    }
  EOT

  type = map(object({
    exact    = optional(list(string), [])
    wildcard = optional(list(string), [])
  }))
  default = {}
}
