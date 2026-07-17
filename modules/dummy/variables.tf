# Required variable for resource identification
variable "instance_name" {
  description = "A unique identifier for this module instance."
  type        = string
}

# 1. Sleep during 'terraform plan' (handled by data.external)
variable "sleep_on_plan" {
  description = "Number of seconds to sleep during the 'plan' phase."
  type        = number
  default     = 0
}

# 2. Sleep during 'terraform apply' (handled by null_resource)
variable "sleep_on_apply" {
  description = "Number of seconds to sleep during the 'apply' phase."
  type        = number
  default     = 0
}

# 3. Crash during 'terraform apply' (handled by null_resource)
variable "crash_on_apply" {
  description = "Set to true to force a non-zero exit code during the 'apply' phase."
  type        = bool
  default     = false
}

# 4. Crash during 'terraform plan' (handled by data.external/script) 
variable "crash_on_plan" {
  description = "Set to true to force a non-zero exit code during the 'plan' phase."
  type        = bool
  default     = false
}

# 5. Tries before apply succeeds (handled by null_resource/local-exec counter)
variable "tries_before_apply_ok" {
  description = "Number of apply attempts that should fail before succeeding. Set to 0 (default) to crash every time when crash_on_apply is true."
  type        = number
  default     = 0

  validation {
    condition     = var.tries_before_apply_ok >= 0
    error_message = "tries_before_apply_ok must be >= 0."
  }
}

# 6. Tries before plan succeeds (handled by data.external / script.js counter)
variable "tries_before_plan_ok" {
  description = "Number of plan attempts that should fail before succeeding. Set to 0 (default) to crash every time when crash_on_plan is true."
  type        = number
  default     = 0

  validation {
    condition     = var.tries_before_plan_ok >= 0
    error_message = "tries_before_plan_ok must be >= 0."
  }
}

