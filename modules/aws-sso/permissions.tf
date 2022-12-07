locals {

  permissions_by_name = {
  
    for permission in local.yaml.permissions-sets: permission.name => permission
  
  }
  
  permissions_custom_policies = flatten([
  
    for permission in local.yaml.permission-sets: [
  
    for custom-policy in permission.custom-policies: "${permission.name},${custom-policy.name},${lookup(custom-policy, "path", "/")}"
  
    ]
  
  ])

}

resource "aws_ssoadmin_permission_set" "permissions" {

  for_each = local.permissions_by_name
  
  instance_arn = var.identity_store_arn
  
  name = each.key
  
  description = lookup(each.value, "description", null)
  
  session_duration = lookup(each.value, "session_duration", null)
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "permissions" {

  for_each = toset(local.permissions_custom_policies)
  
  instance_arn = var.identity_store_arn
 
  permission_set_arn = aws_ssoadmin_permission_set.permissions[split(",", each.value)[0]]

  customer_managed_policy_reference {

    name = split(",", each.value)[1]

    path = split(",", each.value)[2]

  }
}


