# Basic example

Minimal `module` call with empty `members` and `msgraph_roles` and a single `Web` redirect. Use it as a skeleton: set a real `tenant_id`, application `name`, and populate lists for your environment.

## Usage

```bash
terraform init
terraform plan
```

Replace placeholder provider settings (`tenant_id`, and any authentication your stack requires) before apply.

## Configuration

See [`main.tf`](./main.tf).
