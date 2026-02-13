variable "enable_full_sync" {
  description = "If true, the manual replication Lambda is granted secretsmanager:ListSecrets on all resources to support full-account sync. Set to false for strict least-privilege."
  type        = bool
  default     = false
}
variable "existing_bucket_policy_json" {
  description = "Existing bucket policy JSON to merge with CloudTrail statements if using an existing bucket. Required when `manage_s3_bucket_policy` is true and `s3_bucket_name` is set."
  type        = string
  default     = null
}
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
  validation {
    condition = alltrue([
      for account_id, dest in try(jsondecode(var.destinations_json), {}) : alltrue([
        for region_name, region_cfg in try(dest.regions, {}) :
        contains(keys(region_cfg), "kms_key_arn")
      ])
    ])
    error_message = "Each region must contain 'kms_key_arn'."
  }
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
  default     = 600
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

variable "manual_replication_enabled" {
  type        = bool
  default     = true
  description = "Whether to deploy the manual secrets sync Lambda"
}

# ---------------------------------------------------------------------------
# CloudTrail / S3 integration variables (optional)
# ---------------------------------------------------------------------------

variable "s3_bucket_name" {
  description = "(Optional) S3 bucket name where the CloudTrail log is stored. If provided, the module will reuse this bucket instead of creating one."
  type        = string
  default     = ""
}

variable "cloudtrail_arn" {
  description = "(Optional) ARN of an existing CloudTrail. Required if using an existing trail."
  type        = string
  default     = ""
}

variable "cloudtrail_name" {
  description = "(Optional) Name of an existing CloudTrail. Required if using an existing trail."
  type        = string
  default     = ""
}

variable "manage_s3_bucket_policy" {
  description = "If true, the module will apply the minimal S3 bucket policy required for CloudTrail to the chosen bucket. Set to false if the Landing Zone manages bucket policies."
  type        = bool
  default     = true
}


