variable "config" {
  description = "Repository secrets configuration loaded from terraform.tfvars.json."
  type = object({
    repository = string

    actions    = optional(map(string), {})
    codespaces = optional(map(string), {})
    dependabot = optional(map(string), {})
  })
}
