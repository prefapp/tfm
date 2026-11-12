data "ovh_okms_secret" "admin" {
  okms_id      = var.kms_id
  path         = var.admin_secret_path
  include_data = true
}

locals {
  admin = jsondecode(data.ovh_okms_secret.admin.data)

  # Registry host without scheme, such as xxxxxxxx.c1.gra9.container-registry.ovh.net.
  registry_host = trimsuffix(trimprefix(trimprefix(var.registry_url, "https://"), "http://"), "/")

  access_actions = {
    read  = ["pull"]
    write = ["pull", "push"]
  }

  project_robots = merge([
    for project_name, project in var.projects : {
      for robot_name, robot in project.robots : "${project_name}/${robot_name}" => {
        project     = project_name
        name        = robot_name
        access      = robot.access
        description = robot.description
      }
    }
  ]...)
}
