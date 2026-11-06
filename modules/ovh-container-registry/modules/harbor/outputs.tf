output "projects" {
  description = "Names of the Harbor projects managed by this module."
  value       = [for project in harbor_project.project : project.name]
}

output "push_commands" {
  description = "Push commands per Harbor project, as shown in the Harbor UI."
  value = {
    for name, project in harbor_project.project : name => {
      public      = project.public
      docker_tag  = "docker tag SOURCE_IMAGE[:TAG] ${local.registry_host}/${project.name}/REPOSITORY[:TAG]"
      docker_push = "docker push ${local.registry_host}/${project.name}/REPOSITORY[:TAG]"
      podman_push = "podman push IMAGE_ID ${local.registry_host}/${project.name}/REPOSITORY[:TAG]"
      helm_push   = "helm push CHART_PACKAGE oci://${local.registry_host}/${project.name}"
      cnab_push   = "cnab-to-oci push CNAB_PATH --target ${local.registry_host}/${project.name}/REPOSITORY[:TAG] --auto-update-bundle"
    }
  }
}

output "robot_secret_paths" {
  description = "KMS paths of the robot credentials ({username, password}), keyed by robot name for global robots and by <project>/<robot> for project robots."
  value = merge(
    { for name, secret in ovh_okms_secret.global_robot : name => secret.path },
    { for name, secret in ovh_okms_secret.project_robot : name => secret.path },
  )
}
