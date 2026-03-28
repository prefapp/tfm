# Azure Application Registration Terraform Module

## Overview

Este módulo de Terraform permite crear y gestionar un registro de aplicación en Azure Active Directory (Azure AD), incluyendo:
- Creación de la aplicación y service principal.
- Asignación de roles y permisos (incluyendo Microsoft Graph).
- Configuración de credenciales federadas y secretos.
- Soporte para redirecciones y miembros.
- Integración opcional con Azure Key Vault para almacenar secretos.

## Características principales
- Registro de aplicación y service principal en Azure AD.
- Asignación de roles personalizados y de Microsoft Graph.
- Soporte para credenciales federadas (OIDC, GitHub Actions, etc).
- Gestión de secretos con rotación y almacenamiento seguro en Key Vault.
- Configuración flexible de redirecciones y miembros.

## Ejemplo básico de uso

```hcl
module "azure_application" {
  source  = "./modules/azure-application"
  name    = "my-app"
  members = ["user1@dominio.com", "user2@dominio.com"]
  msgraph_roles = [
    {
      id        = "User.Read.All"
      delegated = true
    }
  ]
  redirects = [{
    platform      = "web"
    redirect_uris = ["https://myapp.com/auth/callback"]
  }]
  client_secret = {
    enabled = true
    rotation_days = 90
    keyvault = {
      id = azurerm_key_vault.example.id
      key_name = "my-app-secret"
    }
  }
}
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
