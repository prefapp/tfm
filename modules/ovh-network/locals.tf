locals {
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
