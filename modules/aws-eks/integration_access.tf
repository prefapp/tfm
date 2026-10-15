resource "terraform_data" "backstage_reader_role_validation" {
  count = var.enable_backstage_reader_access_entry ? 1 : 0

  input = {
    role_arn = try(local.backstage_reader_role_arns[0], null)
  }

  lifecycle {
    precondition {
      condition     = length(local.backstage_reader_role_arns) == 1
      error_message = "Backstage access is enabled, but exactly one IAM role named ${var.backstage_reader_role_name} with all configured backstage_reader_role_tags must exist in this AWS account."
    }

    precondition {
      condition     = !contains(keys(var.access_entries), "firestartr_backstage_reader")
      error_message = "access_entries must not define firestartr_backstage_reader when enable_backstage_reader_access_entry is enabled."
    }
  }

}

resource "terraform_data" "argocd_admin_role_validation" {
  count = var.enable_argocd_admin_access_entry ? 1 : 0

  input = {
    role_arn = try(local.argocd_admin_role_arns[0], null)
  }

  lifecycle {
    precondition {
      condition     = length(local.argocd_admin_role_arns) == 1
      error_message = "ArgoCD access is enabled, but exactly one IAM role named ${var.argocd_admin_role_name} with all configured argocd_admin_role_tags must exist in this AWS account."
    }

    precondition {
      condition     = !contains(keys(var.access_entries), "firestartr_argocd_admin")
      error_message = "access_entries must not define firestartr_argocd_admin when enable_argocd_admin_access_entry is enabled."
    }
  }

}
