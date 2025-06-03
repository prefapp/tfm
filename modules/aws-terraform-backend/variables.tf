variable "bucket_name" {
  description = "Name of the S3 Bucket used for storing the Terraform state for the workspaces"
  type        = string
}

variable "bucket_prefix" {
  description = "Prefix to the S3 bucket object"
  type        = string
}

variable "dynamodb_table_name" {
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

variable "force_destroy" {
  description = "Allow destroying the bucket even if it contains state"
  type        = bool
  default     = false
}

variable "enable_versioning" {
  description = "Enable versioning on the bucket"
  type        = bool
  default     = true
}

variable "aws_account_id" {
  description = "AWS Account ID that will assume the role to access the S3 bucket and the dynamodb table"
  type        = string
}

variable "generate_cloudformation_role_for_client_account" {
  description = ""
  type        = bool
  default     = true
}

variable "upload_cloudformation_role" {
  description = ""
  type        = bool
  default     = true
}
