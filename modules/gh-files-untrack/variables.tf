variable "config" {
  description = "Files to untrack from Terraform state so they survive terraform destroy"
  type = object({
    files = list(object({
      repository = string
      file       = string
      branch     = optional(string, "main")
    }))
  })

  validation {
    condition     = length(var.config.files) > 0
    error_message = "At least one file must be provided to untrack."
  }

  validation {
    condition = alltrue([
      for f in var.config.files :
      length(trimspace(f.repository)) > 0 &&
      length(trimspace(f.file)) > 0
    ])
    error_message = "Every file must have non-empty repository and file path."
  }
}
