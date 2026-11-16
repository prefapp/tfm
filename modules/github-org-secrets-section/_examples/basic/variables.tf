variable "config" {
  description = "Organization secrets configuration loaded from terraform.tfvars.json."
  type = object({
    org = string

    actions = optional(map(object({
      value                 = string
      visibility            = optional(string, "all")
      selected_repositories = optional(list(string), [])
    })), {})

    codespaces = optional(map(object({
      value                 = string
      visibility            = optional(string, "all")
      selected_repositories = optional(list(string), [])
    })), {})

    dependabot = optional(map(object({
      value                 = string
      visibility            = optional(string, "all")
      selected_repositories = optional(list(string), [])
    })), {})

    actions_sha256    = optional(map(string), {})
    codespaces_sha256 = optional(map(string), {})
    dependabot_sha256 = optional(map(string), {})
  })
}
