variable "tags" {
  description = "A map of tags to assign to the resource."
  default     = null
  type        = map(string)
}

variable "bucket" {
  description = "The name of the S3 bucket."
  type        = string
}

variable "extra_bucket_iam_policies_json" {
  description = "A array from JSON string representing additional IAM policies to attach to the bucket."
  type        = list(string)
  default     = []
}
variable "region" {
  description = "The AWS region where the S3 bucket will be created."
  type        = string
  default     = null
}

variable "bucket_public_access" {
  description = "If true, block all public access to the bucket."
  type        = bool
  default     = true
}

variable "block_public_acls" {
  description = "Whether to block public ACLs for the bucket."
  type        = bool
  default     = null
}
variable "block_public_policy" {
  description = "Whether to block public bucket policies for the bucket."
  type        = bool
  default     = null
}
variable "ignore_public_acls" {
  description = "Whether to ignore public ACLs for the bucket."
  type        = bool
  default     = null
}
variable "restrict_public_buckets" {
  description = "Whether to restrict public bucket policies for the bucket."
  type        = bool
  default     = null
}

variable "s3_bucket_versioning" {
  description = "The versioning state of the S3 bucket. Valid values are 'Enabled' and 'Suspended'."
  type        = string
  default     = "Suspended"
  validation {
    condition     = contains(["Enabled", "Suspended", "Disabled"], var.s3_bucket_versioning)
    error_message = "s3_bucket_versioning must be either 'Enabled', 'Suspended' or 'Disabled'."
  }
}

variable "object_lock_enabled" {
  description = "A boolean that indicates whether object lock is enabled for the bucket."
  type        = bool
  default     = null
}

variable "lifecycle_rules" {
  description = "A list of lifecycle rules to apply to the bucket."
  type = list(object({
    id     = string
    status = optional(string)
    filter = optional(object({
      prefix = optional(string)
      and = optional(object({
        prefix                   = optional(string)
        object_size_greater_than = optional(number)
        object_size_less_than    = optional(number)
      }))
    }))
    enabled = optional(bool)
    prefix  = optional(string)
    tags    = optional(map(string))
    transitions = optional(list(object({
      days          = number
      storage_class = string
    })))
    expiration = optional(object({
      days                         = optional(number)
      expired_object_delete_marker = optional(bool)
    }))
    noncurrent_version_expiration = optional(object({
      newer_noncurrent_versions = optional(number)
      noncurrent_days           = optional(number)
    }))

  }))
  default = []
}


## Replication variables

variable "s3_replication_destination" {
  description = "Object containing the replication destination configuration."
  type = object({
    account       = string
    bucket_arn    = string
    storage_class = string
    filter = optional(object({
      prefix = optional(string)
      tags   = optional(map(string))
      and = optional(object({
        prefix = optional(string)
        tags   = optional(map(string))
      }))
    }))
  })
  default = null
}

## Replication variables

variable "s3_replication_source" {
  description = "Object containing the replication source configuration."
  type = object({
    account  = string
    role_arn = string
    filter = optional(object({
      prefix = optional(string)
      tags   = optional(map(string))
      and = optional(object({
        prefix = optional(string)
        tags   = optional(map(string))
      }))
    }))
  })
  default = null
}