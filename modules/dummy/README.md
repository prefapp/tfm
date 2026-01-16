# Terraform Diagnostic Executor Module

This module is designed for DevOps testing and CI/CD pipeline validation. It provides features to simulate network latency (sleep) and catastrophic failures (crash) at both the terraform plan and terraform apply stages.

It leverages the external data source (for plan-time checks) and null_resource with local-exec provisioners (for apply-time actions).

## Prerequisites

- Terraform: Required version ~> 1.0.

- Node.js: Must be installed and accessible via the PATH on the machine running terraform plan and terraform apply.

- Required Providers: hashicorp/external and hashicorp/null.

## Module Usage

The module requires four primary boolean and numeric variables to control its diagnostic behavior.

Example

```terraform
module "diagnostic_test" {
  source           = "./node-executor"

  # Base input
  instance_name    = "ci-pipeline-check"

  # PLAN TIME CONTROLS
  sleep_on_plan    = 5           # Delays 'terraform plan' by 5 seconds
  crash_on_plan    = false       # Set to true to force 'terraform plan' failure

  # APPLY TIME CONTROLS
  sleep_on_apply   = 10          # Delays 'terraform apply' by 10 seconds
  crash_on_apply   = false       # Set to true to force 'terraform apply' failure
}

output "plan_status" {
  value = module.diagnostic_test.plan_message
}
```


## Inputs

## Inputs

| Name | Description | Type | Default | Control Phase | 
|---|---|---|---|---|
| `instance_name` | A unique identifier for the diagnostic run. | `string` | `"default-test"` | Both | 
| `sleep_on_plan` | Duration in seconds to delay the `terraform plan` execution. | `number` | `0` | Plan | 
| `crash_on_plan` | If set to true, forces `terraform plan` to fail immediately. | `bool` | `false` | Plan | 
| `sleep_on_apply` | Duration in seconds to delay the `terraform apply` execution. | `number` | `0` | Apply | 
| `crash_on_apply` | If set to true, forces `terraform apply` to fail immediately. | `bool` | `false` | Apply |


## Outputs

| Name | Description | Value Source | 
| ----- | ----- | ----- | 
| `plan_message` | A status message from the plan-time script execution. | `data.external` | 
| `plan_timestamp` | The timestamp when the plan-time script executed. | `data.external` | 
| `plan_slept_for_s` | The actual seconds the script slept during plan. | `data.external` | 
| `plan_crashed` | Status indicating if the crash logic was executed during plan. | `data.external` |


## Diagnostic Scenarios

### 1. Test Plan Failure

To test how your CI/CD pipeline handles a plan failure:

```terraform
# Set crash_on_plan to true via command line
terraform plan -var="crash_on_plan=true"
```



Expected Result: The terraform plan command will exit with a non-zero exit code (failure) as the data "external" source executes the Node.js script, which calls process.exit(1).

### 2. Test Apply Failure

To test infrastructure deployment failure:

```terraform
# Set crash_on_apply to true via command line
terraform apply -auto-approve -var="crash_on_apply=true"
```

Expected Result: The terraform apply command will fail when it attempts to create the null_resource.diagnostic_crash_logic because its local-exec provisioner executes the exit 1 shell command.

### 3. Test Apply Timeout/Latency

To test pipeline timeouts during execution:

```
# Set a 30 second delay during the apply phase
terraform apply -auto-approve -var="sleep_on_apply=30"
```



