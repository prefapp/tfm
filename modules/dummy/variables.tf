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

