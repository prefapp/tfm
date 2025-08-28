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
  description = "AWS client account ID"
  type        = string
}

variable "create_aux_role" {
  description = "Decide whether to generate a specific auxiliary role to the backend"
  type        = bool
  default     = false
}

variable "external_main_role" {
  description = "Role name to assume by the main role, in the client account"
  type        = string
}

variable "external_aux_role" {
  description = "Role name available to be assumed by the auxiliary role, in the client account"
  type        = string
  default     = ""
}

variable "generate_cloudformation_role_for_external_account" {
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

variable "main_role" {
  description = "Main role configuration"
  type = object({
    name                                 = string
    aws_account_id                       = optional(string)
    cloudformation_external_account_role = optional(string)
    oidc_trust_policies = optional(
      object({
        provider_urls             = list(string)
        oidc_audiences            = list(string)
        fully_qualified_subjects  = list(string)
        subjects_with_wildcards   = list(string)
        fully_qualified_audiences = list(string)
      })
    )
  })
}

variable "aux_role" {
  description = "Auxiliary role configuration"
  type = object({
    name                                 = string
    aws_account_id                       = optional(string)
    cloudformation_external_account_role = optional(string)
    oidc_trust_policies = optional(
      object({
        provider_urls             = list(string)
        oidc_audiences            = list(string)
        fully_qualified_subjects  = list(string)
        subjects_with_wildcards   = list(string)
        fully_qualified_audiences = list(string)
      })
    )
  })
}
