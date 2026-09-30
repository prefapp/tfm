data "ovh_cloud_projects" "projects" {}

locals {
  matching_projects = [
    for project in data.ovh_cloud_projects.projects.projects : project
    if lower(project.description) == lower(var.project_description)
  ]

  service_name = one(local.matching_projects).service_name
}

data "ovh_cloud_project_kube" "my_kube_cluster" {
  service_name = local.service_name
  kube_id      = var.kube_id
}

resource "terraform_data" "credential_generation" {
  for_each = var.identities

  triggers_replace = each.value.credential_generation
}

resource "kubernetes_service_account_v1" "identity" {
  for_each = local.token_identities

  metadata {
    name      = each.key
    namespace = each.value.service_account_namespace
  }

}

resource "kubernetes_secret_v1" "token" {
  for_each = local.token_identities

  metadata {
    name      = "${each.key}-token"
    namespace = each.value.service_account_namespace

    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account_v1.identity[each.key].metadata[0].name
    }
  }

  type = "kubernetes.io/service-account-token"

  lifecycle {
    replace_triggered_by = [terraform_data.credential_generation[each.key]]
  }
}

resource "time_sleep" "token_propagation" {
  for_each = local.token_identities

  create_duration = "30s"
  triggers = {
    secret_uid = kubernetes_secret_v1.token[each.key].metadata[0].uid
  }
}

data "kubernetes_secret_v1" "token" {
  for_each = local.token_identities

  metadata {
    name      = kubernetes_secret_v1.token[each.key].metadata[0].name
    namespace = kubernetes_secret_v1.token[each.key].metadata[0].namespace
  }

  depends_on = [time_sleep.token_propagation]
}

resource "tls_private_key" "client" {
  for_each = local.certificate_identities

  algorithm = "RSA"
  rsa_bits  = 3072

  lifecycle {
    replace_triggered_by = [terraform_data.credential_generation[each.key]]
  }
}

resource "tls_cert_request" "client" {
  for_each = local.certificate_identities

  private_key_pem = tls_private_key.client[each.key].private_key_pem

  subject {
    common_name = each.key
  }
}

resource "kubernetes_certificate_signing_request_v1" "client" {
  for_each = local.certificate_identities

  metadata {
    name = "${var.cluster_name}-${each.key}-tf"
  }

  spec {
    request            = tls_cert_request.client[each.key].cert_request_pem
    signer_name        = "kubernetes.io/kube-apiserver-client"
    expiration_seconds = each.value.expiration_seconds
    usages = [
      "digital signature",
      "key encipherment",
      "client auth",
    ]
  }

  auto_approve = true

  timeouts {
    create = "10m"
  }

  lifecycle {
    replace_triggered_by = [terraform_data.credential_generation[each.key]]
  }
}

resource "kubernetes_cluster_role_binding_v1" "cluster" {
  for_each = local.cluster_bindings

  metadata {
    name = "${each.key}-${each.value.role}"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = each.value.role == "readonly" ? "view" : "edit"
  }

  dynamic "subject" {
    for_each = contains(each.value.auth_methods, "certificate") ? ["certificate"] : []
    content {
      kind      = "User"
      name      = each.key
      api_group = "rbac.authorization.k8s.io"
    }
  }

  dynamic "subject" {
    for_each = contains(each.value.auth_methods, "token") ? ["token"] : []
    content {
      kind      = "ServiceAccount"
      name      = each.key
      namespace = each.value.service_account_namespace
    }
  }
}

resource "kubernetes_role_binding_v1" "namespace" {
  for_each = local.namespace_bindings

  metadata {
    name      = "${each.value.identity_name}-${each.value.role}"
    namespace = each.value.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = each.value.role == "readonly" ? "view" : "edit"
  }

  dynamic "subject" {
    for_each = contains(keys(each.value.methods), "certificate") ? ["certificate"] : []
    content {
      kind      = "User"
      name      = each.value.identity_name
      api_group = "rbac.authorization.k8s.io"
    }
  }

  dynamic "subject" {
    for_each = contains(keys(each.value.methods), "token") ? ["token"] : []
    content {
      kind      = "ServiceAccount"
      name      = each.value.identity_name
      namespace = var.identities[each.value.identity_name].service_account_namespace
    }
  }
}

locals {
  credential_kubeconfigs = {
    for key, access in local.identity_methods : key => yamlencode({
      apiVersion  = "v1"
      kind        = "Config"
      preferences = {}
      clusters = [{
        name = var.cluster_name
        cluster = {
          server                       = data.ovh_cloud_project_kube.my_kube_cluster.kubeconfig_attributes[0].host
          "certificate-authority-data" = data.ovh_cloud_project_kube.my_kube_cluster.kubeconfig_attributes[0].cluster_ca_certificate
        }
      }]
      users = [{
        name = access.identity_name
        user = access.method == "token" ? {
          token = data.kubernetes_secret_v1.token[access.identity_name].data["token"]
          } : {
          "client-certificate-data" = base64encode(kubernetes_certificate_signing_request_v1.client[access.identity_name].certificate)
          "client-key-data"         = base64encode(tls_private_key.client[access.identity_name].private_key_pem)
        }
      }]
      contexts = [{
        name = "${var.cluster_name}-${access.identity_name}-${access.method}"
        context = {
          cluster = var.cluster_name
          user    = access.identity_name
        }
      }]
      "current-context" = "${var.cluster_name}-${access.identity_name}-${access.method}"
    })
  }
}

resource "terraform_data" "configuration" {
  input = {
    identities               = var.identities
    publish_to_okms          = var.publish_to_okms
    export_local_kubeconfigs = var.export_local_kubeconfigs
  }

  lifecycle {
    precondition {
      condition     = !var.publish_to_okms || length(local.missing_secret_paths) == 0
      error_message = "Cada método habilitado requiere una ruta secret_paths.<método> cuando publish_to_okms es true. Métodos sin ruta: ${join(", ", local.missing_secret_paths)}."
    }
    precondition {
      condition     = length(local.configured_secret_destinations) == length(distinct(local.configured_secret_destinations))
      error_message = "Cada identidad/método debe publicar en una ruta OKMS distinta; no se pueden reutilizar paths."
    }
  }
}

resource "ovh_okms_secret" "credential" {
  for_each = var.publish_to_okms ? local.identity_methods : {}

  okms_id = var.okms_id
  path    = lookup(each.value.identity.secret_paths, each.value.method, "")

  metadata = {
    custom_metadata = {
      cluster    = var.cluster_name
      identity   = each.value.identity_name
      method     = each.value.method
      managed_by = "terraform-04-kubernetes-access"
    }
  }

  version = {
    data = jsonencode({ kubeconfig = local.credential_kubeconfigs[each.key] })
  }

  depends_on = [terraform_data.configuration]
}

resource "local_sensitive_file" "kubeconfig" {
  for_each = var.export_local_kubeconfigs ? local.identity_methods : {}

  filename        = "${path.module}/.local-credentials-${replace(each.key, "/", "-")}.yaml"
  file_permission = "0600"
  content         = local.credential_kubeconfigs[each.key]

  lifecycle {
    precondition {
      condition = each.value.method == "token" ? try(
        trimspace(data.kubernetes_secret_v1.token[each.value.identity_name].data["token"]) != "",
        false
      ) : true
      error_message = "La credencial ${each.key} aún no está disponible en Kubernetes."
    }
  }
}
