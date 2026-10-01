variable "project_description" {
  description = "Description of the OVHcloud Public Cloud project containing the MKS cluster, for example prefapp."
  type        = string

  validation {
    condition     = trimspace(var.project_description) != ""
    error_message = "project_description is required and must not be empty."
  }
}

variable "kube_id" {
  description = "OVHcloud Managed Kubernetes Service cluster ID."
  type        = string

  validation {
    condition     = trimspace(var.kube_id) != ""
    error_message = "kube_id is required and must not be empty."
  }
}

variable "cluster_name" {
  description = "Cluster name used in certificate requests and kubeconfigs."
  type        = string
  nullable    = false

  validation {
    condition     = length(var.cluster_name) <= 40 && can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.cluster_name))
    error_message = "cluster_name must be a DNS name of up to 40 characters using lowercase letters, numbers, and hyphens."
  }
}

variable "identities" {
  description = <<-EOT
    Access identity map. Keys are the certificate CN and ServiceAccount name.
    auth_methods accepts certificate, token, or both. Each enabled method must have
    a secret_paths.<method> entry when publish_to_okms is enabled.
    role accepts readonly (ClusterRole view) or readwrite (ClusterRole edit).
    scope accepts cluster (all namespaces) or namespaces (an explicit list).
  EOT
  type = map(object({
    role                      = string
    scope                     = string
    auth_methods              = optional(set(string), ["certificate"])
    namespaces                = optional(set(string), [])
    service_account_namespace = optional(string, "kube-system")
    secret_paths              = optional(map(string), {})
    expiration_seconds        = optional(number, 7776000)
    credential_generation     = optional(number, 0)
  }))

  nullable = false

  default = {}

  validation {
    condition = alltrue([
      for name, identity in var.identities :
      length(name) <= 63 &&
      can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", name)) &&
      contains(["readonly", "readwrite"], identity.role) &&
      contains(["cluster", "namespaces"], identity.scope) &&
      (identity.scope == "cluster" ? length(identity.namespaces) == 0 : length(identity.namespaces) > 0) &&
      length(identity.auth_methods) > 0 &&
      alltrue([for method in identity.auth_methods : contains(["certificate", "token"], method)]) &&
      (!contains(identity.auth_methods, "certificate") || (identity.expiration_seconds >= 600 && identity.expiration_seconds <= 31536000)) &&
      alltrue([for method, path in identity.secret_paths : contains(["certificate", "token"], method) && trimspace(path) != ""]) &&
      alltrue([for method in keys(identity.secret_paths) : contains(identity.auth_methods, method)]) &&
      identity.credential_generation >= 0 &&
      floor(identity.credential_generation) == identity.credential_generation &&
      length(identity.service_account_namespace) <= 63 &&
      can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", identity.service_account_namespace))
    ])
    error_message = "Each identity must have a valid DNS name, role readonly/readwrite, valid scope, at least one certificate/token method, a valid ServiceAccount namespace, a non-negative integer generation, and non-empty paths for enabled methods. Certificate validity must be between 600 and 31536000 seconds (up to one year on OVH MKS)."
  }
}

variable "okms_id" {
  description = "OVHcloud Secret Manager (OKMS) service ID where kubeconfigs will be published."
  type        = string

  validation {
    condition     = trimspace(var.okms_id) != ""
    error_message = "okms_id is required and must not be empty."
  }
}

variable "publish_to_okms" {
  description = "Publish each enabled kubeconfig as a new JSON version at the OKMS path specified for its identity and method."
  type        = bool
  default     = true
}

variable "export_local_kubeconfigs" {
  description = "Write enabled kubeconfigs locally with 0600 permissions, in addition to publishing them to OKMS when applicable."
  type        = bool
  default     = false
}
