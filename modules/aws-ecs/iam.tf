resource "aws_iam_role" "this" {
  count              = var.service_name != null ? 1 : 0
  name_prefix        = var.iam_role_name
  assume_role_policy = local.ecs_assume_role_policy
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  for_each   = var.service_name != null ? toset(var.policy_arns) : []
  role       = aws_iam_role.this[0].name
  policy_arn = each.value
}
