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
  type = list(object({
    id        = string
    delegated = bool
  }))
  description = "Microsoft Graph entries for this app. Each `id` is written to `azuread_application.required_resource_access` as `type = Scope` (use the OAuth2 delegated **permission scope id** / UUID for Microsoft Graph from the manifest or portal, not a display name). When `delegated` is true, the module also creates `azuread_app_role_assignment` on Microsoft Graph and sets `app_role_id` via `lookup(data.azuread_service_principal.msgraph.app_role_ids, id)`; that map is keyed by Graph **application role values** (per the AzureAD provider), which are not always the same string as the OAuth2 scope UUID—verify keys from the data source or `terraform plan` if assignments fail. When `delegated` is false, only the `required_resource_access` entry is created (no Graph app role assignment)."
}

variable "extra_role_assignments" {
  type = list(object({
    role_definition_name = string
    scope                = string
  }))
  description = "The list of extra role assignments to be added to the Azure App Registration."
  default     = []
}

variable "client_secret" {
  type = object({
    enabled       = bool
    rotation_days = optional(number)
    keyvault = optional(object({
      id       = string
      key_name = string
    }))
  })
  description = "The client secret configuration for the Azure App Registration."
  default = {
    enabled  = false
    keyvault = null
  }
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
  default     = []
}
