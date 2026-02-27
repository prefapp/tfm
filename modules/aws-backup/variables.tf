variable "aws_kms_key_vault_arn" {
  description = "ARN of the KMS key used to encrypt the backup vault. If not provided, the default AWS Backup vault encryption will be used."
  type        = string
  default     = null
}

variable "aws_backup_vault" {
  description = "List of objects defining the backup vault configuration, including backup plans and replication rules."
  type = list(object({
    vault_name        = string
    vault_region      = optional(string)
    vault_tags        = optional(map(string))
    vault_kms_key_arn = optional(string)

    plan = optional(list(object({
      name                         = string
      rule_name                    = string
      schedule                     = string
      schedule_expression_timezone = optional(string)
      start_window                 = optional(number)
      completion_window            = optional(number)
      # Structure for dynamic conditions in aws_backup_selection
      # Example usage:
      # backup_selection_conditions = {
      #   string_equals = [
      #     { key = "aws:ResourceTag/Component", value = "rds" }
      #   ]
      #   string_like = [
      #     { key = "aws:ResourceTag/Application", value = "app*" }
      #   ]
      #   string_not_equals = [
      #     { key = "aws:ResourceTag/Backup", value = "false" }
      #   ]
      #   string_not_like = [
      #     { key = "aws:ResourceTag/Environment", value = "test*" }
      #   ]
      # }
      backup_selection_conditions = optional(object({
        string_equals     = optional(list(object({ key = string, value = string })))
        string_like       = optional(list(object({ key = string, value = string })))
        string_not_equals = optional(list(object({ key = string, value = string })))
        string_not_like   = optional(list(object({ key = string, value = string })))
      }))
      backup_selection_arn_resources = optional(list(string))
      lifecycle = optional(object({
        cold_storage_after = number
        delete_after       = number
      }))
      advanced_backup_setting = optional(list(object({
        backup_options = map(string)
        resource_type  = string
      })))
      scan_action = optional(list(object({
        malware_scanner  = string
        scan_action_type = string
      })))
      recovery_point_tags = optional(map(string))
      tags                = optional(map(string))
      copy_action = optional(list(object({
        destination_vault_arn = string
        delete_after          = optional(number)
      })))
      })
    ))
    })
  )
  default = []

}

variable "tags" {
  description = "Default tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "copy_action_default_values" {
  description = "Default values for the copy action configuration in backup plan rules. If not provided, the copy action will not be created."
  type = object({
    destination_account_id = string
    destination_region     = string
    delete_after           = number
  })
  default = {
    destination_account_id = null
    destination_region     = null
    delete_after           = 14
  }
}

variable "enable_cross_account_backup" {
  description = "Enable cross-account backup in AWS Backup global settings. If set to true, the module will manage the global settings resource to enable cross-account backup. If set to false, you can configure it separately if needed."
  type        = bool
  default     = false
}