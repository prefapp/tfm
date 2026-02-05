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

  validation {
    condition     = length([for r in var.aws_regions_replica : r if r == var.aws_region]) == 0
    error_message = "aws_regions_replica must not contain the primary aws_region."
  }
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
  default     = "Symmetric encryption KMS key"
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

variable "kms_alias_prefix" {
  description = "The prefix for the alias that will use the KMS key. The full alias will be in the format 'alias/{prefix}-{random_id.suffix.hex}'"
  type        = string
  default     = ""
}

variable "administrator_role_name" {
  description = "Name of the IAM role to grant KMS administrator permissions. Set to null to disable granting permissions to this role."
  type        = string
  default     = "Administrator"
}

variable "via_service" {
  description = "AWS services that are allowed to use the KMS key. This is used to create a condition in the key policy that allows access through these services. Example: 'rds', 's3'"
  type        = list(string)
  default     = null
}

variable "user_roles_with_read_write" {
  description = "List of IAM role names to grant read/write permissions to the KMS key. Set to null to disable granting permissions to any additional roles."
  type        = list(string)
  default     = []
}

variable "user_roles_with_read" {
  description = "List of IAM role names or users to grant read permissions to the KMS key. Set to null to disable granting permissions to any additional roles."
  type        = list(string)
  default     = []
}