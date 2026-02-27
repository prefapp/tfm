resource "aws_backup_global_settings" "global" {
  for_each = var.enable_cross_account_backup ? { "global" : "global" } : {}
  global_settings = {
    "isCrossAccountBackupEnabled" = "true"
  }
}