# The 'external' data source executes the script for plan-time calculations and side-effects.
# This runs during both 'plan' and 'apply'.
data "external" "script_executor" {
  # Execute the node binary directly for better reliability and bypass complex shell nesting issues.
  program = [
    "node", 
    "${path.module}/script.js"
  ]

  # Pass only the variables relevant to the PLAN phase to the script
  query = {
    instance_name        = var.instance_name
    sleep_duration       = var.sleep_on_plan
    enable_crash         = var.crash_on_plan
    tries_before_plan_ok = var.tries_before_plan_ok
  }
}

# 1. Base Resource: Executes if apply logic is present, and provides an ID output.
resource "null_resource" "diagnostic_base_logic" {
  triggers = {
    run_always = timestamp()
  }
}

# 2. Conditional Sleep: This resource is only created if 'sleep_on_apply' > 0.
resource "null_resource" "conditional_sleep" {
  count = var.sleep_on_apply > 0 ? 1 : 0

  # Force re-creation on every apply to ensure the provisioner runs
  triggers = {
    run_always = timestamp()
  }
  
  provisioner "local-exec" {
    # Executes the command using a standard sh interpreter
    interpreter = ["sh", "-c"] 
    
    # Echo message and then sleep. We use count[0] to access the instance.
    command = "echo '--- APPLY-TIME DELAY --- Sleeping for ${var.sleep_on_apply} seconds...' && sleep ${var.sleep_on_apply}"
    when    = create
  }
}

# 3. Conditional Crash: This resource is only created if 'crash_on_apply' is true.
resource "null_resource" "conditional_crash" {
  count = var.crash_on_apply ? 1 : 0
  
  # Force re-creation on every apply to ensure the provisioner runs
  triggers = {
    run_always = timestamp()
  }

  provisioner "local-exec" {
    interpreter = ["sh", "-c"]

    command = <<-EOT
      COUNTER_FILE="/tmp/tfm-dummy-counter-${var.instance_name}"
      TRIES="${var.tries_before_apply_ok}"
      if [ "$TRIES" -eq 0 ]; then
        echo "--- APPLY-TIME CRASH (infinite, tries_before_apply_ok=0) ---"
        exit 1
      fi
      if [ -f "$COUNTER_FILE" ]; then
        COUNT=`cat "$COUNTER_FILE"`
      else
        COUNT=0
      fi
      COUNT=`expr "$COUNT" + 1`
      echo "$COUNT" > "$COUNTER_FILE"
      if [ "$COUNT" -le "$TRIES" ]; then
        echo "--- APPLY-TIME CRASH (attempt $COUNT/$TRIES) ---"
        exit 1
      fi
      echo "--- APPLY-TIME SUCCESS after $COUNT attempts ---"
      rm -f "$COUNTER_FILE"
    EOT

    when    = create
  }
}

# --- Module Outputs ---

# Output from the PLAN-TIME script
output "script_message" {
  description = "The message returned by the external script (ran during plan)."
  value       = data.external.script_executor.result.message
}

# Output from the PLAN-TIME script
output "script_timestamp" {
  description = "The timestamp returned by the external script (ran during plan)."
  value       = data.external.script_executor.result.timestamp
}

# Check to ensure the base apply-time resource was created
output "apply_resource_id" {
    description = "The ID of the base null resource, indicating apply logic executed."
    value       = null_resource.diagnostic_base_logic.id
}
