variable "name" {
  description = "Base name for the Lambda and associated resources"
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
