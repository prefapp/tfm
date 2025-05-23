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

  value = data.aws_caller_identity.current.account_id

}

output "eks" {

  value = module.eks

}

output "summary" {
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
     - IAM Cluster Role: ${split("/", var.cluster_iam_role_arn != null ? var.cluster_iam_role_arn : module.eks.cluster_iam_role_arn)[1]}
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
           - Launch template version: ${lookup(node_group_value, "launch_template_version", module.eks.eks_managed_node_groups[node_group_key].launch_template_latest_version)}
           - Labels:
         ${join("\n", [for k, v in node_group_value.labels : "\t- ${k}: ${v}"])}
       EOT
  ])}

     ----------------------------------------------------------------------------
     Add-ons
     ----------------------------------------------------------------------------
     ${join("\n", [
  for addon_key, addon_value in local.cluster_addons :
  format(
    " - %s\n \t- Addon Version: %s\n\t- Advanced configuration:\t%s",
    addon_key,
    lookup(addon_value, "addon_version", "latest"),
    replace(
      jsonencode(lookup(addon_value, "configuration_values", {})),
      "\n", "\n\t\t\t\t\t"
    )
  )
  ])}

     ----------------------------------------------------------------------------
     Network Details:
     ----------------------------------------------------------------------------
     - Account ID: ${local.account_id}
     - VPC ID: ${coalesce(local.vpc_id, var.vpc_id)}
     - VPC Subnets:
     ${join("\n", [
  for subnet_key, subnet_value in zipmap(
    range(length(coalesce(local.private_subnet_ids, var.subnet_ids))),
    coalesce(local.private_subnet_ids, var.subnet_ids)
  ) :
  format("\t %s: %s", subnet_key + 1, subnet_value)
])}

     ----------------------------------------------------------------------------
     IAM Roles:
     ----------------------------------------------------------------------------

         | Service             | Created |
         |---------------------|---------|
         | ALB Ingress IAM     | ${var.create_alb_ingress_iam}    |
         | CloudWatch IAM      | ${var.create_cloudwatch_iam}    |
         | EFS Driver IAM      | ${var.create_efs_driver_iam}   |
         | External DNS IAM    | ${var.create_external_dns_iam}    |
         | Parameter Store IAM | ${var.create_parameter_store_iam}    |

     ############################################################################

   SUMMARY
}


output "debug" {
  value = local.mixed_addons
}
