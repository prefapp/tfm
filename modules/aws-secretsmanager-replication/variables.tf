variable "name" {
  description = "Base name for the Lambda and associated resources"
  type        = string
}

variable "prefix" {
  description = "Prefix to use for naming resources."
  type        = string
}

variable "destinations_json" {
  description = "JSON describing accounts, regions and KMS keys for replication"
  type        = string
}

variable "allowed_assume_roles" {
  description = "List of IAM roles the Lambda can assume for cross-account replication"
  type        = list(string)
}

variable "environment_variables" {
  description = "Additional environment variables passed to the Lambda"
  type        = map(string)
  default     = {}
}

variable "enable_tag_replication" {
  description = "Whether to replicate tags from the source secret (used by the code, not Terraform)"
  type        = bool
  default     = true
}

variable "eventbridge_enabled" {
  description = "Whether to create the EventBridge rule that triggers the Lambda"
  type        = bool
  default     = true
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 10
}

variable "lambda_memory" {
  description = "Lambda memory in MB"
  type        = number
  default     = 128
}

variable "tags" {
  description = "Tags applied to all resources created by this module"
  type        = map(string)
  default     = {}
}

# ---------------------------------------------------------------------------
# CloudTrail / S3 integration variables (optional)
# ---------------------------------------------------------------------------

variable "s3_bucket_name" {
  description = "(Optional) S3 bucket name where the CloudTrail log is stored. If provided, the module will reuse this bucket instead of creating one."
  type        = string
  default     = ""
}

variable "cloudtrail_name" {
  description = "(Optional) Name of the CloudTrail trail to monitor for Secrets Manager events. If provided, the module will reuse this trail instead of creating one."
  type        = string
  default     = ""
}

variable "manage_s3_bucket_policy" {
  description = "If true, the module will apply the minimal S3 bucket policy required for CloudTrail to the chosen bucket. Set to false if the Landing Zone manages bucket policies."
  type        = bool
  default     = true
}

variable "source_secret_arns" {
  description = "Optional list of source Secrets Manager ARNs or ARN prefixes to restrict read permissions for the Lambda. Use concrete ARNs or prefixes in production; default allows all."
  type        = list(string)
  default     = ["*"]
}

variable "destination_secret_arns" {
  description = "Optional list of destination Secrets Manager ARNs or ARN prefixes to restrict write permissions for the Lambda. Use concrete ARNs or prefixes in production; default allows all."
  type        = list(string)
  default     = ["*"]
}

variable "kms_key_arns" {
  description = "Optional list of KMS key ARNs used by source/destination secrets to restrict KMS permissions for the Lambda. Use concrete key ARNs in production; default allows all."
  type        = list(string)
  default     = ["*"]

  validation {
    condition     = length(var.kms_key_arns) > 0
    error_message = "kms_key_arns must be a non-empty list (use [\"*\"] to allow all or provide specific KMS key ARNs)."
  }
}
