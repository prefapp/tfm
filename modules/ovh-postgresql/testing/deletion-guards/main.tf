variable "deletion_protection" {
  type    = bool
  default = true
}

variable "children" {
  type    = map(string)
  default = { app = "database-id" }
}

variable "events_file" {
  type = string
}

resource "terraform_data" "child_operation" {
  for_each = var.children

  triggers_replace = "${terraform_data.cluster.id}/${each.value}"
  input = {
    events_file = var.events_file
  }

  provisioner "local-exec" {
    when    = destroy
    command = "printf '%s\\n' child-deleted >> '${self.input.events_file}'"
  }
}

resource "terraform_data" "deletion_guard" {
  for_each = { for key, child in terraform_data.child_operation : key => child.id }

  triggers_replace = each.value
  input            = var.deletion_protection

  provisioner "local-exec" {
    when    = destroy
    command = "sh '${path.module}/../../scripts/deletion-guard.sh' '${self.input}' 'Deletion protection is enabled; apply with deletion_protection = false before deleting managed PostgreSQL resources.'"
  }
}

resource "terraform_data" "deletion_guard_barrier" {
  input      = var.deletion_protection
  depends_on = [terraform_data.deletion_guard]

  provisioner "local-exec" {
    when    = destroy
    command = "sh '${path.module}/../../scripts/deletion-guard.sh' '${self.input}' 'Deletion protection is enabled; apply with deletion_protection = false before destroying this module.'"
  }
}

resource "terraform_data" "cluster" {
  triggers_replace = "module"
  input            = var.events_file

  provisioner "local-exec" {
    when    = destroy
    command = "printf '%s\\n' cluster-deleted >> '${self.input}'"
  }
}
