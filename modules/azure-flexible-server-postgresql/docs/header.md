# Azure PostgreSQL Flexible Server Terraform Module

## Overview

Este módulo de Terraform permite crear y gestionar un servidor PostgreSQL Flexible en Azure, con soporte para:
- Creación de servidor, configuraciones, firewall y restauración PITR.
- Integración con Key Vault para contraseñas seguras.
- Soporte para redes privadas, subredes y DNS privados.
- Configuración avanzada de autenticación, backup y mantenimiento.

## Características principales
- Creación de PostgreSQL Flexible Server con opciones avanzadas.
- Soporte para restauración Point-in-Time (PITR).
- Gestión de configuraciones y reglas de firewall.
- Integración con Key Vault y redes privadas.
- Ejemplo realista de configuración.

## Ejemplo completo de uso

```yaml
values:
  resource_group: "example-resource-group"
  tags_from_rg: true
  key_vault:
    tags:
     value: "tag1"
    #name: "key-vault-name"
    #resource_group_name: "key-vault-resource-group-name"
  vnet:
    tags:
      value: "tag1"
    #name: "example-vnet"
    #resource_group_name: "vnet-resource-group-name"
  subnet_name: "example-subnet"
  dns_private_zone_name: "dns.private.zone.example.com"
  administrator_password_key_vault_secret_name: "flexible-server-secret-example-test"
  password_lenght: 10
  postgresql_flexible_server:
    location: "westeurope"
    name: "example-flexible-server"
    version: "15"
    administrator_login: "psqladmin"
    public_network_access_enabled: false
    storage_mb: "65536"
    sku_name: "GP_Standard_D2ds_v5"
    backup_retention_days: 30
    #create_mode: "PointInTimeRestore"
    #source_server_id: "/subscriptions/xxxxxx-xxxx-xxxx-xxxxxx/resourceGroups/example-resource-group/providers/Microsoft.DBforPostgreSQL/flexibleServers/example-flexible-server"
    #point_in_time_restore_time_in_utc: "2025-02-21T09:35:43Z"
    maintenance_window:
      day_of_week: 6
      start_hour: 0
      start_minute: 0
    authentication:
      active_directory_auth_enabled: false
      password_auth_enabled: true
  postgresql_flexible_server_configuration:
    azure.extensions:
      name: "azure.extensions"
      value: "extension1,extension2"
    configuration1:
      name: "example-configuration"
      value: "TRUE"
```

## Notas
- Puedes usar Key Vault para gestionar la contraseña del administrador.
- Si usas red privada, debes especificar subnet y DNS privado.
- Para restauración PITR, consulta la sección de la documentación sobre create_mode.

## Estructura de archivos

```
.
├── main.tf
├── variables.tf
├── outputs.tf
├── README.md
├── CHANGELOG.md
└── docs/
    ├── header.md
    └── footer.md
```
