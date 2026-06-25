variable "enable_full_sync" {
  description = "If true, the manual replication Lambda is granted ssm:DescribeParameters on all resources to support full-account sync. Set to false for strict least-privilege."
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
    condition = can(alltrue([
      for _, destination in jsondecode(var.destinations_json) :
      length(trimspace(tostring(destination.role_arn))) > 0
    ]))
    error_message = "Each destination in destinations_json must define a non-empty `role_arn`."
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
  description = "List of IAM roles the Lambda can assume for cross-account replication"
  type        = list(string)
  default     = []
}

variable "environment_variables" {
  description = "Additional environment variables passed to the Lambda"
  type        = map(string)
  default     = {}
}

variable "enable_tag_replication" {
  description = "Whether to replicate tags from the source parameter. Terraform uses this to configure Lambda behavior (environment variables) and to conditionally grant source tag-read permissions (`ssm:ListTagsForResource`)."
  type        = bool
  default     = true
}

variable "eventbridge_enabled" {
  description = "Whether to create the EventBridge rule that triggers the Lambda"
  type        = bool
  default     = false
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
  description = "Whether to deploy the manual parameter sync Lambda"
}
