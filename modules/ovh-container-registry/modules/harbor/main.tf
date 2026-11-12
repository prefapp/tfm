resource "harbor_project" "project" {
  for_each = var.projects

  name   = each.key
  public = each.value.public
}

# Harbor secret policy: 8-128 characters with upper case, lower case and digits.
resource "random_password" "global_robot" {
  for_each = var.global_robots

  length      = 32
  special     = false
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
}

resource "harbor_robot_account" "global" {
  for_each = var.global_robots

  name        = each.key
  description = each.value.description
  level       = "system"
  secret      = random_password.global_robot[each.key].result

  permissions {
    kind      = "project"
    namespace = "*"

    dynamic "access" {
      for_each = local.access_actions[each.value.access]
      content {
        action   = access.value
        resource = "repository"
      }
    }
  }
}

resource "random_password" "project_robot" {
  for_each = local.project_robots

  length      = 32
  special     = false
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
}

resource "harbor_robot_account" "project" {
  for_each = local.project_robots

  name        = each.value.name
  description = each.value.description
  level       = "project"
  secret      = random_password.project_robot[each.key].result

  permissions {
    kind      = "project"
    namespace = harbor_project.project[each.value.project].name

    dynamic "access" {
      for_each = local.access_actions[each.value.access]
      content {
        action   = access.value
        resource = "repository"
      }
    }
  }
}

resource "ovh_okms_secret" "global_robot" {
  for_each = var.global_robots

  okms_id = var.kms_id
  path    = "${var.registry_name}/${each.key}"

  metadata = {
    max_versions             = 10
    deactivate_version_after = "0s"
    custom_metadata = merge(var.secret_custom_metadata, {
      registry = var.registry_name
      access   = each.value.access
    })
  }

  version = {
    data = jsonencode({
      username = harbor_robot_account.global[each.key].full_name
      password = random_password.global_robot[each.key].result
    })
  }

  lifecycle {
    precondition {
      condition     = "${var.registry_name}/${each.key}" != var.admin_secret_path
      error_message = "Global robot '${each.key}' would overwrite the Harbor admin secret at ${var.admin_secret_path}. Use another robot name."
    }
  }
}

resource "ovh_okms_secret" "project_robot" {
  for_each = local.project_robots

  okms_id = var.kms_id
  path    = "${var.registry_name}/${each.key}"

  metadata = {
    max_versions             = 10
    deactivate_version_after = "0s"
    custom_metadata = merge(var.secret_custom_metadata, {
      registry = var.registry_name
      project  = each.value.project
      access   = each.value.access
    })
  }

  version = {
    data = jsonencode({
      username = harbor_robot_account.project[each.key].full_name
      password = random_password.project_robot[each.key].result
    })
  }
}
