locals {
  # Same project lookup as ovh-mks: the name set in the OVHcloud console can
  # live in project_name or in description.
  selected_projects = [
    for project in data.ovh_cloud_projects.projects.projects : project
    if var.project_id != null ? (
      project.project_id == var.project_id || project.service_name == var.project_id
      ) : (
      var.project_name != null ? (
        lower(project.project_name) == lower(var.project_name) || lower(project.description) == lower(var.project_name)
      ) : false
    )
  ]
  service_name = try(one(local.selected_projects).service_name, null)
}

data "ovh_cloud_projects" "projects" {}

data "ovh_cloud_project_capabilities_containerregistry_filter" "plan" {
  service_name = local.service_name == null ? "" : local.service_name
  region       = var.region
  plan_name    = var.plan_name

  lifecycle {
    precondition {
      condition     = var.project_name != null || var.project_id != null
      error_message = "Set project_id or project_name to select the Public Cloud project."
    }

    precondition {
      condition     = local.service_name != null
      error_message = "Could not find exactly one OVHcloud project. Check project_id or project_name; if both are set, project_id takes precedence."
    }
  }
}

data "ovh_okms_resource" "kms" {
  id = var.kms_id
}
