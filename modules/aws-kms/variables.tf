variable "aws_region" {
  description = "Region to create kms key"
  type        = string
  default     = "eu-west-1"
}

variable "aws_accounts_access" {
  description = "Enable access to kms for additional AWS accounts"
  type        = list(string)
  default     = []
}

variable "aws_regions_replica" {
  description = "List of AWS regions where KMS key replicas should be created"
  type        = list(string)
  default     = []
}


variable "deletion_window_in_days" {
  description = "The waiting period, specified in days, before the KMS key is deleted. Default is 30 days."
  type        = number
  default     = 30

  validation {
    condition     = var.deletion_window_in_days >= 7 && var.deletion_window_in_days <= 30
    error_message = "deletion_window_in_days must be between 7 and 30 days (inclusive), as required by AWS KMS."
  }
}

variable "enable_key_rotation" {
  description = "Specifies whether key rotation is enabled. Default is true."
  type        = bool
  default     = true
}

variable "description" {
  description = "Description of the KMS key"
  type        = string
  default     = "An example symmetric encryption KMS key"
}

variable "multiregion" {
  description = "Specifies whether the KMS key is multi-region. Default is true."
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

variable "alias" {
  description = "The alias that will use the KMS key"
  type        = string
  default     = null
}