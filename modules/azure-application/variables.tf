variable "name" {
  type        = string
  description = "The name of the Azure App Registration."
}

variable "redirects" {
  type = list(object({
    platform      = string
    redirect_uris = list(string)
  }))
  description = "The redirect configuration for the Azure App Registration."
  validation {
    condition     = alltrue([for r in var.redirects : contains(["PublicClient", "SPA", "Web"], r.platform)])
    error_message = "Each platform must be one of: PublicClient, SPA, or Web."
  }
}

variable "members" {
  type        = list(string)
  description = "The list of members to be added to the Azure App Registration."
}

variable "msgraph_roles" {
  type        = list(string)
  description = "The list of Microsoft Graph roles to be assigned to the Azure App Registration. e.g. User.Read.All"
}

variable "extra_role_assignments" {
  type = list(object({
    role_definition_name = string
    scope                = string
  }))
  description = "The list of extra role assignments to be added to the Azure App Registration."
}

variable "client_secret" {
  type = object({
    enabled       = bool
    rotation_days = number
    keyvault = optional(object({
      id       = string
      key_name = string
    }))
  })
  description = "The client secret configuration for the Azure App Registration."
}

variable "federated_credentials" {
  type = list(object({
    display_name = string
    audiences    = list(string)
    issuer       = string
    subject      = string
    description  = optional(string)
  }))
  description = "The federated credentials configuration for the Azure App Registration."
}
