variable "project_id" {
  description = "Optional Public Cloud project ID or service_name; takes precedence over project_name."
  type        = string
  default     = null
}

variable "project_name" {
  description = "Optional Public Cloud project name; matched against OVHcloud project_name and description."
  type        = string
  default     = null
}

variable "cluster_name" {
  description = "Name of the Managed Kubernetes cluster."
  type        = string
}

variable "cluster_plan" {
  description = "MKS cluster plan, such as free or standard."
  type        = string
}

variable "update_policy" {
  description = "Managed Kubernetes cluster update policy."
  type        = string
  default     = "MINIMAL_DOWNTIME"

  validation {
    condition = contains([
      "ALWAYS_UPDATE",
      "MINIMAL_DOWNTIME",
      "NEVER_UPDATE",
    ], var.update_policy)
    error_message = "update_policy must be ALWAYS_UPDATE, MINIMAL_DOWNTIME, or NEVER_UPDATE."
  }
}

variable "region" {
  description = "OVHcloud region for the cluster."
  type        = string
}

variable "network_name" {
  description = "Exact name of the existing private network to attach to the cluster."
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR of the existing subnet Kubernetes will use, for example 10.20.0.0/16."
  type        = string
}

variable "node_flavor" {
  description = "Worker node flavor available in the selected region."
  type        = string
}

variable "node_pools" {
  description = "Cluster node pools with non-negative integer capacities where min_nodes <= desired_nodes <= max_nodes; an empty availability_zones list leaves zone placement unspecified."
  type = map(object({
    desired_nodes      = number
    min_nodes          = number
    max_nodes          = number
    availability_zones = list(string)
  }))

  validation {
    condition = alltrue([
      for pool in values(var.node_pools) : try(
        pool.min_nodes >= 0 &&
        pool.desired_nodes >= 0 &&
        pool.max_nodes >= 0 &&
        floor(pool.min_nodes) == pool.min_nodes &&
        floor(pool.desired_nodes) == pool.desired_nodes &&
        floor(pool.max_nodes) == pool.max_nodes &&
        pool.min_nodes <= pool.desired_nodes &&
        pool.desired_nodes <= pool.max_nodes,
        false
      )
    ])
    error_message = "Each node pool must have non-negative integer capacities that satisfy min_nodes <= desired_nodes <= max_nodes."
  }
}

variable "autoscale" {
  description = "Enable autoscaling for each node pool."
  type        = bool
}

variable "anti_affinity" {
  description = "Enable anti-affinity for instances in each node pool."
  type        = bool
}

variable "cluster_version" {
  description = "Managed Kubernetes cluster version."
  type        = string
  nullable    = false
}
