# MongoDB Atlas Project

## Overview

This module creates a MongoDB Atlas project with database users and network project access via IP whitelist.

## DOC

- [Resource terraform - mongodbatlas_project](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/project)
- [Resource terraform - mongodbatlas_database_user](https://registry.terraform.io/providers/mongodb/mongodbatlas/1.23.0/docs/resources/database_user)
- [Resource terraform - mongodbatlas_project_ip_access_list](https://registry.terraform.io/providers/mongodb/mongodbatlas/1.23.0/docs/resources/project_ip_access_list)

## Notes

- This module presupposes that:
  - The `organization_id` is already created.

## Usage

### Set a module

```terraform
module "mongodb-atlas-project" {
  source = "git::https://github.com/prefapp/tfm.git//modules/mongodb-atlas-project?ref=<version>"
}
```

### Set a data .tfvars

#### Example

```hcl
mongo_region = "westeurope"
provider_name = "azure"
org_id = "XXXXXXXXXXXXXXXXXXXXXXXX"
project_name = "my-project"
database_users = {
  user1 = {
    username = "user1"
    password = "password1"
    auth_database_name = "admin"
    roles = {
      role_name = "readWriteAnyDatabase"
      database_name = "admin"
    }
    scopes = {
      name = "project"
      type = "CLUSTER"
    }
  }
  user2 = {
    username = "user2"
    password = "password2"
    auth_database_name = "admin"
    roles = {
      role_name = "readWriteAnyDatabase"
      database_name = "admin"
    }
    scopes = {
      name = "project"
      type = "CLUSTER"
    }
  }
}
whitelist_ips = [
  {
    ip = "1.2.3.4"
    name = "my-ip"
  },
  {
    ip = "5.6.7.8"
    name = "my-ip2"
  }
]
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_mongo_region"></a> [mongo_region](#input_mongo_region) | The mongo region. | `string` | n/a | yes |
| <a name="input_provider_name"></a> [provider_name](#input_provider_name) | The provider name. | `string` | n/a | yes |
| <a name="input_org_id"></a> [org_id](#input_org_id) | The organization ID. | `string` | n/a | yes |
| <a name="input_project_name"></a> [project_name](#input_project_name) | The name of the project. | `string` | n/a | yes |
| <a name="input_database_users"></a> [database_users](#input_database_users) | A map of database users. | `map(object({ username = string, password = string, auth_database_name = string, roles = object({ role_name = string, database_name = string }), scopes = object({ name = string, type = string }) }))` | n/a | yes |
| <a name="input_whitelist_ips"></a> [whitelist_ips](#input_whitelist_ips) | The whitelist IPs. | `list(object({ ip = string, name = string }))` | n/a | yes |
