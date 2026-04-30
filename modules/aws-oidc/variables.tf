variable "create_oidc_provider" {
  description = "Create OIDC provider for GitHub Actions"
  type        = bool
  default     = true
  nullable    = false
}

variable "subs" {
  description = "List of GitHub OIDC subject claims allowed to assume the role"
  type        = list(string)
}
