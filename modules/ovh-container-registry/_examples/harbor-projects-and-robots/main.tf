# Harbor projects and robot accounts for an existing registry.
#
# Apply this in a different Terraform state from the registry itself: the
# harbor provider needs the registry URL and admin credentials while planning,
# and those do not exist until the registry is applied. Feed the inputs from
# the registry outputs (remote state, Firestartr output references, or values).

variable "kms_id" {
  description = "Registry module kms_id output."
  type        = string
}

variable "registry_name" {
  description = "Registry module registry_name output."
  type        = string
}

variable "registry_url" {
  description = "Registry module registry_url output."
  type        = string
}

variable "admin_secret_path" {
  description = "Registry module admin_secret_path output."
  type        = string
}

module "harbor" {
  source = "git::https://github.com/prefapp/tfm.git//modules/ovh-container-registry/modules/harbor?ref=ovh-container-registry-vx.y.z"

  kms_id            = var.kms_id
  registry_name     = var.registry_name
  registry_url      = var.registry_url
  admin_secret_path = var.admin_secret_path

  # System robots with access to every project, present and future.
  # Credentials are stored in the KMS at <registry_name>/<robot>.
  global_robots = {
    cicd = {
      access      = "write"
      description = "CI/CD push and pull on every project"
    }
    k8s = {
      access      = "read"
      description = "Kubernetes image pull on every project"
    }
  }

  projects = {
    # Private project (default) with no project-scoped robots.
    apps = {}

    # Public project: anyone can pull without credentials. Only one robot
    # can push; its credentials go to <registry_name>/charts/publisher.
    charts = {
      public = true
      robots = {
        publisher = {
          access      = "write"
          description = "Publishes Helm charts"
        }
      }
    }
  }
}

output "push_commands" {
  description = "Ready-to-use push commands per project."
  value       = module.harbor.push_commands
}

output "robot_secret_paths" {
  description = "KMS paths of the robot credentials."
  value       = module.harbor.robot_secret_paths
}
