locals {

  accounts_permissions_groups = flatten([

    for account, permission_sets in local.yaml.attachments : [

      for permission_name, permission_set in permission_sets : [

        for group in (permission_set.groups != null ? permission_set.groups : []) : "${account},${permission_name},${group}"

      ]

    ]

  ])

  accounts_permissions_users = flatten([

    for account, permission_sets in local.yaml.attachments : [

      for permission_name, permission_set in permission_sets : [

        for user in (permission_set.users != null ? permission_set.users : []) : "${account},${permission_name},${user}"

      ]

    ]

  ])

}



resource "aws_ssoadmin_account_assignment" "accounts-permissions-groups" {

  for_each = toset(local.accounts_permissions_groups)

  instance_arn = var.identity_store_arn

  target_id = split(",", each.value)[0]

  target_type = "AWS_ACCOUNT"

  permission_set_arn = aws_ssoadmin_permission_set.permissions[split(",", each.value)[1]].arn

  principal_type = "GROUP"

  principal_id = split("/", aws_identitystore_group.groups[split(",", each.value)[2]].id)[1]

  depends_on = [
 
    aws_ssoadmin_permission_set.permissions

  ]

}

resource "aws_ssoadmin_account_assignment" "accounts-permissions-users" {

  for_each = toset(local.accounts_permissions_users)

  instance_arn = var.identity_store_arn

  target_id = split(",", each.value)[0]

  target_type = "AWS_ACCOUNT"

  permission_set_arn = aws_ssoadmin_permission_set.permissions[split(",", each.value)[1]].arn

  principal_type = "USER"

  principal_id = split("/", aws_identitystore_user.users[split(",", each.value)[2]].id)[1]

  depends_on = [
 
    aws_ssoadmin_permission_set.permissions

  ]
}
