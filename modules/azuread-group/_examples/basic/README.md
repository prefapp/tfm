# Basic example

Minimal `module` call with empty `members`, `owners`, `subscription_roles`, and `directory_roles`. Use it as a skeleton: set real `tenant_id`, group `name`, and populate the lists for your environment.

## Usage

```bash
terraform init
terraform plan
```

Replace placeholder provider settings (`tenant_id`, and any authentication your stack requires) before apply.

## Configuration

See [`main.tf`](./main.tf).
