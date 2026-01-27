# Azure Custom Role Terraform Module

## Overview

Este módulo de Terraform permite crear un rol personalizado (Custom Role) en Azure, especificando acciones, data actions y los ámbitos (scopes) donde se puede asignar.

## Características principales
- Creación de roles personalizados en Azure.
- Definición flexible de acciones, data actions, not actions y not data actions.
- Soporte para múltiples scopes asignables.

## Ejemplo completo de uso

### HCL
```hcl
module "custom_role" {
  source = "./modules/azure-customrole"
  name   = "Custom Role"
  assignable_scopes = ["/subscriptions/xxx", "/subscriptions/yyy"]
  permissions = {
    actions = [
      "Microsoft.Compute/disks/read",
      "Microsoft.Compute/disks/write",
    ]
    not_actions = [
      "Microsoft.Compute/disks/read",
      "Microsoft.Compute/disks/write",
    ]
  }
}
```

### YAML
```yaml
name: "Custom Role"
assignable_scopes:
  - "/subscriptions/xxx"
  - "/subscriptions/yyy"
permissions:
  actions:
    - "Microsoft.Compute/disks/read"
    - "Microsoft.Compute/disks/write"
  notActions:
    - "Microsoft.Authorization/*/Delete"
    - "Microsoft.Authorization/*/Write"
```

## Estructura de archivos

```
.
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── README.md
├── CHANGELOG.md
└── docs/
    ├── header.md
    └── footer.md
```
