# Azure Managed Disks Terraform Module

## Overview

Este módulo de Terraform permite crear y gestionar discos gestionados (Managed Disks) en Azure, con soporte para:
- Creación de múltiples discos con diferentes configuraciones.
- Asignación opcional de roles sobre los discos.
- Etiquetado flexible y herencia de etiquetas del Resource Group.

## Características principales
- Creación de discos gestionados de diferentes tipos y tamaños.
- Asignación opcional de roles a los discos (por ejemplo, Contributor).
- Soporte para tags y herencia desde el Resource Group.
- Manejo de cambios de tamaño ignorados por el lifecycle (útil para CSI Driver).

## Ejemplo completo de uso

```yaml
values:
  tags_from_rg: true
  resource_group_name: "REDACTED-RESOURCE-GROUP"
  location: "REDACTED-LOCATION"
  disks:
      - name: disk-1
        storage_account_type: StandardSSD_LRS
      - name: disk-2
      - name: disk-3
      - name: disk-4
```

## Notas
- Se pueden crear discos vacíos o basados en otro disco.
- No es obligatorio asignar un rol a un disco.
- El tamaño del disco se ignora en los cambios para evitar conflictos con el CSI Driver.

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
