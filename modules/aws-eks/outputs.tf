/*
  This Terraform script is used to output various details about the EKS cluster
  configuration. It outputs the AWS account ID, the EKS module, a detailed
  summary of the EKS configuration, and debug information.

  - The summary includes details about the EKS cluster, node groups, add-ons,
  network details, users, and IAM roles.

  - The debug output is related to mixed addons in the EKS cluster.

  This script is useful for getting a comprehensive overview of the EKS cluster
  configuration and for debugging purposes.
*/

output "account_id" {
  description = "AWS Account ID where the EKS cluster is deployed. Null when ECO_DR is enabled."
  value       = local.account_id_output
}

output "eks" {
  description = "EKS module details. Null when ECO_DR is enabled."
  value       = try(module.eks[0], null)
}

output "summary" {
  description = "Summary of the EKS cluster configuration"
  value = <<-SUMMARY

     ############################################################################
     #### SUMARY Amazon EKS Configuration
     ############################################################################

     ----------------------------------------------------------------------------
     EKS Cluster Details
     ----------------------------------------------------------------------------
     - Cluster Name: ${var.cluster_name}
     - Cluster Version: ${var.cluster_version}
     - Cluster Region: ${var.region}
     - IAM Cluster Role: ${local.eco_dr_enabled ? "disabled by ECO_DR" : split("/", var.cluster_iam_role_arn != null ? var.cluster_iam_role_arn : module.eks[0].cluster_iam_role_arn)[1]}
     - Cluster Tags:
     ${join("\n", [
  for tag_key, tag_value in var.tags :
  format("\t - %s: %s", tag_key, tag_value)
  ])}

     ----------------------------------------------------------------------------
     Node Groups
     ----------------------------------------------------------------------------
     ${join("\n", [
  for node_group_key, node_group_value in var.node_groups :
  <<-EOT
       - ${node_group_key}
           - Instance type: ${join(", ", node_group_value.instance_types)}
           - Desired capacity: ${node_group_value.desired_size}
           - Min size: ${node_group_value.min_size}
           - Max size: ${node_group_value.max_size}
           - Launch template version: ${local.eco_dr_enabled ? "disabled by ECO_DR" : coalesce(lookup(node_group_value, "launch_template_version", null), try(module.eks[0].eks_managed_node_groups[node_group_key].launch_template_latest_version, "unknown"))}
           - Labels:
         ${join("\n", [for k, v in node_group_value.labels : "\t- ${k}: ${v}"])}
       EOT
  ])}

     ----------------------------------------------------------------------------
     Add-ons
     ----------------------------------------------------------------------------
     ${join("\n", [
  for addon_key, addon_value in try(module.eks[0].cluster_addons, {}) :
  format(
    " - %s\n \t- Addon Version: %s\n\t- ServiceAccount IAM Role: %s\n\t- Advanced configuration:\t%s",
    addon_key,
    coalesce(lookup(addon_value, "addon_version", null), "latest"),
    coalesce(lookup(addon_value, "service_account_role_arn", null), "none"),
    replace(
      jsonencode(lookup(addon_value, "configuration_values", {})),
      "\n", "\n\t\t\t\t\t"
    )
  )
  ])}

     ----------------------------------------------------------------------------
     Network Details:
     ----------------------------------------------------------------------------
     - Account ID: ${local.account_id_summary}
     - VPC ID: ${try(data.aws_vpc.selected[0].id, "disabled by ECO_DR")}
     - VPC Subnets:
     ${join("\n", [
  for subnet_key, subnet_value in zipmap(
    range(length(try(coalescelist(try(data.aws_subnets.filtered[0].ids, []), var.subnet_ids, []), []))),
    try(coalescelist(try(data.aws_subnets.filtered[0].ids, []), var.subnet_ids, []), [])
  ) :
  format("\t %s: %s", subnet_key + 1, subnet_value)
])}

     ----------------------------------------------------------------------------
     IAM Roles:
     ----------------------------------------------------------------------------

         | Service             | Created |
         |---------------------|---------|
         | ALB Ingress IAM     | ${!local.eco_dr_enabled && var.create_alb_ingress_iam}    |
         | CloudWatch IAM      | ${!local.eco_dr_enabled && var.create_cloudwatch_iam}    |
         | EFS Driver IAM      | ${!local.eco_dr_enabled && var.create_efs_driver_iam}   |
         | External DNS IAM    | ${!local.eco_dr_enabled && var.create_external_dns_iam}    |
         | Parameter Store IAM | ${!local.eco_dr_enabled && var.create_parameter_store_iam}    |

     ############################################################################

   SUMMARY
}

output "debug" {
  description = "Debug information for mixed addons. Empty when ECO_DR is enabled."
  value = {
    for key, value in local.mixed_addons : key => value
    if !local.eco_dr_enabled
  }
}
