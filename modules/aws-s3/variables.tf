variable "tags" {
  description = "A map of tags to assign to the resource."
  default     = null
  type        = map(string)
}

variable "bucket" {
  description = "The name of the S3 bucket."
  type        = string
}

variable "create_bucket" {
  description = "Whether to create a new bucket or use an existing one with the name specified in the 'bucket' variable."
  type        = bool
  default     = true
}
variable "extra_bucket_iam_policies_json" {
  description = "An array from JSON string representing additional IAM policies to attach to the bucket."
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

variable "s3_replication_role_suffix" {
  description = "Suffix to add to the replication role name. This is useful to avoid name conflicts when creating multiple replication roles in the same account."
  type        = string
  default     = "-replication"
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
    abort_incomplete_multipart_upload = optional(object({
      days_after_initiation = number
    }))

  }))
  default = []
}

variable "default_lifecycle_rules" {
  description = "A list of lifecycle rules when replication or versioning is enabled to apply to the bucket."
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
    abort_incomplete_multipart_upload = optional(object({
      days_after_initiation = number
    }))
  }))
  default = [
    {
      id     = "Permanently delete noncurrent versions of objects after 3 days"
      status = "Enabled"
      noncurrent_version_expiration = {
        noncurrent_days = 3
      }
    },
    {
      id     = "Delete expired objects and incomplete multipart uploads (after 2 days)"
      status = "Enabled"
      abort_incomplete_multipart_upload = {
        days_after_initiation = 2
      }
      expiration = {
        expired_object_delete_marker = true
      }
    }
  ]
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