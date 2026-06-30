variable "enable_full_sync" {
  description = "If true, the replication Lambda is granted ssm:DescribeParameters on all resources to support full-account sync. Set to false for strict least-privilege."
  type        = bool
  default     = false
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
    condition     = can(jsondecode(var.destinations_json))
    error_message = "destinations_json must be valid JSON."
  }

  validation {
    condition     = can(tomap(jsondecode(var.destinations_json)))
    error_message = "destinations_json must decode to a JSON object/map keyed by destination account ID (arrays/lists are not allowed)."
  }

  validation {
    condition     = can(tomap(jsondecode(var.destinations_json))) && length(tomap(jsondecode(var.destinations_json))) > 0
    error_message = "destinations_json must contain at least one destination account entry."
  }

  validation {
    condition = can([
      for account_id, destination in jsondecode(var.destinations_json) : {
        account_id = tostring(account_id)
        role_arn   = tostring(destination.role_arn)
        regions    = tomap(destination.regions)
      }
    ])
    error_message = "destinations_json must be a map of account IDs to objects with required keys `role_arn` (string) and `regions` (map/object)."
  }

  validation {
    condition = alltrue([
      for _, destination in jsondecode(var.destinations_json) :
      can(regex("^arn:[^:]+:iam::[0-9]{12}:role/.+", tostring(destination.role_arn)))
    ])
    error_message = "Each destination in destinations_json must define a valid IAM role ARN in `role_arn` (for example, arn:aws:iam::123456789012:role/MyRole)."
  }
}

variable "add_region_prefix_to_name" {
  description = <<-EOT
If true, the destination parameter name is region-prefixed.
For simple names: "myparameter" -> "us-east-1-myparameter".
For path-style names: "/my/parameter" -> "/us-east-1/my/parameter".
If false, the original name is used. Default: false.
This helps avoid collisions if you replicate parameters with the same name from multiple regions.
EOT
  type        = bool
  default     = false
}

variable "allowed_assume_roles" {
  description = "Additional IAM role ARNs the Lambda is allowed to assume (destination role_arn values from destinations_json are always included)."
  type        = list(string)
  default     = []
}

variable "environment_variables" {
  description = "Additional environment variables passed to the Lambda"
  type        = map(string)
  default     = {}
}

variable "enable_tag_replication" {
  description = "Whether to copy/prune *source* tags from the source parameter. Replication metadata tags (origin-account, origin-region, latest-version) are always applied. Terraform also uses this to conditionally grant source tag-read permissions (`ssm:ListTagsForResource`)."
  type        = bool
  default     = true
}

variable "eventbridge_enabled" {
  description = "Whether to create the EventBridge rule that triggers the Lambda"
  type        = bool
  default     = false
}

variable "async_failure_visibility_enabled" {
  description = "Whether to create async failure visibility resources (Lambda async failure destination DLQ and CloudWatch alarms) when EventBridge is enabled."
  type        = bool
  default     = true
}

variable "lambda_async_maximum_retry_attempts" {
  description = "Maximum retry attempts for asynchronous Lambda invocations (valid range: 0..2)."
  type        = number
  default     = 2

  validation {
    condition     = var.lambda_async_maximum_retry_attempts >= 0 && var.lambda_async_maximum_retry_attempts <= 2 && floor(var.lambda_async_maximum_retry_attempts) == var.lambda_async_maximum_retry_attempts
    error_message = "lambda_async_maximum_retry_attempts must be an integer between 0 and 2."
  }
}

variable "replication_failure_alarm_actions" {
  description = "List of ARNs (for example SNS topics) to notify when replication failure alarms trigger."
  type        = list(string)
  default     = []
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

variable "assume_role_duration_seconds" {
  description = "Duration (in seconds) for STS AssumeRole sessions used to access destination accounts. Must be between 900 and 43200 seconds, and cannot exceed the destination role MaxSessionDuration."
  type        = number
  default     = 3600

  validation {
    condition     = var.assume_role_duration_seconds >= 900 && var.assume_role_duration_seconds <= 43200 && floor(var.assume_role_duration_seconds) == var.assume_role_duration_seconds
    error_message = "assume_role_duration_seconds must be an integer between 900 and 43200 seconds."
  }
}

variable "tags" {
  description = "Tags applied to all resources created by this module"
  type        = map(string)
  default     = {}
}

variable "manual_replication_enabled" {
  type        = bool
  default     = true
  description = "DEPRECATED: Kept for backward compatibility. Manual replication is now always available through the unified Lambda. This variable no longer has any effect."
}
