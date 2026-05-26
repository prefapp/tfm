output "script_message" {
  description = "The message returned by the external script (ran during plan)."
  value       = data.external.script_executor.result.message
}

output "script_timestamp" {
  description = "The timestamp returned by the external script (ran during plan)."
  value       = data.external.script_executor.result.timestamp
}

output "apply_resource_id" {
  description = "The ID of the base null resource, indicating apply logic executed."
  value       = null_resource.diagnostic_base_logic.id
}
