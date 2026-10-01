terraform {
  required_version = ">= 1.5.0"
}

module "kubernetes_access" {
  source = "../.."

  project_description      = var.project_description
  kube_id                  = var.kube_id
  cluster_name             = "production"
  okms_id                  = var.okms_id
  publish_to_okms          = true
  export_local_kubeconfigs = false

  identities = {
    argocd = {
      role         = "readwrite"
      scope        = "cluster"
      auth_methods = ["certificate", "token"]
      secret_paths = {
        certificate = "mks/production/argocd/certificate"
        token       = "mks/production/argocd/token"
      }
    }
  }
}

variable "project_description" {
  type        = string
  description = "OVHcloud Public Cloud project description containing the MKS cluster."
}

variable "kube_id" {
  type        = string
  description = "OVHcloud Managed Kubernetes Service cluster ID."
}

variable "okms_id" {
  type        = string
  description = "OVHcloud Secret Manager service ID."
}
