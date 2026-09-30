variable "project_description" {
  description = "Descripción del proyecto OVHcloud Public Cloud que contiene el clúster MKS, por ejemplo prefapp."
  type        = string

  validation {
    condition     = trimspace(var.project_description) != ""
    error_message = "project_description es obligatorio y no puede estar vacío."
  }
}

variable "kube_id" {
  description = "Identificador del clúster OVHcloud Managed Kubernetes Service."
  type        = string

  validation {
    condition     = trimspace(var.kube_id) != ""
    error_message = "kube_id es obligatorio y no puede estar vacío."
  }
}

variable "cluster_name" {
  description = "Nombre del clúster, usado en solicitudes de certificado y kubeconfigs."
  type        = string
  nullable    = false

  validation {
    condition     = length(var.cluster_name) <= 40 && can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.cluster_name))
    error_message = "cluster_name debe ser un nombre DNS de hasta 40 caracteres en minúsculas, números y guiones."
  }
}

variable "identities" {
  description = <<-EOT
    Matriz de identidades de acceso. Las claves son el CN del certificado y el nombre
    de la ServiceAccount. auth_methods admite certificate, token o ambos. Cada método
    habilitado debe tener secret_paths.<método> cuando publish_to_okms está activo.
    role admite readonly (ClusterRole view) o readwrite (ClusterRole edit).
    scope admite cluster (todos los namespaces) o namespaces (lista explícita).
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

  default = {
    argocd = {
      role         = "readwrite"
      scope        = "cluster"
      auth_methods = ["certificate", "token"]
      secret_paths = { certificate = "mks/prefapp-pro/argocd/certificate", token = "mks/prefapp-pro/argocd/token" }
    }
    developers-readonly = {
      role         = "readonly"
      scope        = "cluster"
      auth_methods = ["certificate"]
      secret_paths = { certificate = "mks/prefapp-pro/developers-readonly/certificate" }
    }
    developers-readwrite = {
      role         = "readwrite"
      scope        = "cluster"
      auth_methods = ["certificate"]
      secret_paths = { certificate = "mks/prefapp-pro/developers-readwrite/certificate" }
    }
  }

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
      (!var.publish_to_okms || alltrue([for method in identity.auth_methods : contains(keys(identity.secret_paths), method) && trimspace(lookup(identity.secret_paths, method, "")) != ""])) &&
      alltrue([for method, path in identity.secret_paths : contains(["certificate", "token"], method) && trimspace(path) != ""]) &&
      alltrue([for method in keys(identity.secret_paths) : contains(identity.auth_methods, method)]) &&
      identity.credential_generation >= 0 &&
      floor(identity.credential_generation) == identity.credential_generation &&
      length(identity.service_account_namespace) <= 63 &&
      can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", identity.service_account_namespace))
    ])
    error_message = "Cada identidad requiere nombre DNS válido, role readonly/readwrite, scope válido, al menos un método certificate/token, namespace de ServiceAccount válido, generación entera no negativa y rutas no vacías para métodos habilitados. La vigencia de certificados debe ser de 600 a 31536000 segundos (máximo un año en OVH MKS)."
  }
}

variable "okms_id" {
  description = "Identificador del servicio OVHcloud Secret Manager (OKMS) donde se publicarán los kubeconfigs."
  type        = string

  validation {
    condition     = trimspace(var.okms_id) != ""
    error_message = "okms_id es obligatorio y no puede estar vacío."
  }
}

variable "publish_to_okms" {
  description = "Publica cada kubeconfig habilitado como una nueva versión JSON en la ruta OKMS indicada por identidad y método."
  type        = bool
  default     = true
}

variable "export_local_kubeconfigs" {
  description = "Escribe localmente los kubeconfigs habilitados con permisos 0600, además de publicarlos en OKMS si corresponde."
  type        = bool
  default     = false
}
