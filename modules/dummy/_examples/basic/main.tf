# Basic example: simulate a 5-second delay during apply.
# Useful for validating CI/CD pipeline timeout and failure-handling logic.
# Set crash_on_destroy = true to test destroy-time failure behavior.

module "dummy" {
  source = "git::https://github.com/prefapp/tfm.git//modules/dummy"

  instance_name = "ci-pipeline-check"

  # PLAN TIME CONTROLS
  sleep_on_plan = 0
  crash_on_plan = false

  # APPLY TIME CONTROLS
  sleep_on_apply = 5     # Delays 'terraform apply' by 5 seconds
  crash_on_apply = false

  # DESTROY TIME CONTROLS
  sleep_on_destroy = 0
  crash_on_destroy = false # Set to true to force 'terraform destroy' failure
}

output "script_message" {
  value = module.dummy.script_message
}

output "apply_resource_id" {
  value = module.dummy.apply_resource_id
}
