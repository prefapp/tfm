output "account_id" {

  value = data.aws_caller_identity.current.account_id

}

output "eks_summary" {
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
    - IAM Cluster Role: ${split("/", var.cluster_iam_role_arn)[1]}
    - Cluster Tags: 
    ${join("\n", [
      for tag_key, tag_value in var.cluster_tags :
      format("\t - %s: %s", tag_key, tag_value )
    ])}

    ----------------------------------------------------------------------------
    Node Groups
    ----------------------------------------------------------------------------
    ${join("\n", [
      for node_group_key, node_group_value in var.node_groups :
      <<-EOT
      - ${node_group_key}
          - Instance type: ${join(", ", node_group_value.instance_types)}
          - Desired capacity: ${node_group_value.desired_capacity}
          - Min size: ${node_group_value.min_size}
          - Max size: ${node_group_value.max_size}
          - Launch template version: ${node_group_value.launch_template_version}
          - Labels:
        ${join("\n", [for k, v in node_group_value.labels : "\t- ${k}: ${v}"])}
      EOT
    ])}

    ----------------------------------------------------------------------------
    Add-ons
    ----------------------------------------------------------------------------
    ${join("\n", [
      for addon_key, addon_value in var.cluster_addons :
      format(
        " - %s\n \t- Addon Version: %s\n\t- Advanced configuration:\t%s",
        addon_key,
        addon_value.addon_version,
        replace(
          lookup(addon_value, "configuration_values", "None"), 
          "\n", "\n\t\t\t\t\t"
        )
      )
    ])}

    ----------------------------------------------------------------------------
    Network Details:
    ----------------------------------------------------------------------------
    - Account ID: ${local.account_id}
    - VPC ID: ${var.vpc_id}
    - VPC Subnets: 
    ${join("\n", [
      for subnet_key, subnet_value in var.subnet_ids :
      format("\t %s: %s", subnet_key + 1, subnet_value )
    ])}

    ----------------------------------------------------------------------------
    Users:
    ----------------------------------------------------------------------------

        | Username             | Group          |
        |----------------------|----------------|
    ${join("\n", [
      for user in var.aws_auth_users :
      format("    | %-20s | %-14s |", user.username, user.groups[0])
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
