resource "aws_iam_role" "this" {
  name               = var.iam_role_name
  assume_role_policy = local.ecs_assume_role_policy
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  for_each   = toset(var.policy_arns)
  role       = aws_iam_role.this.name
  policy_arn = each.value
}
