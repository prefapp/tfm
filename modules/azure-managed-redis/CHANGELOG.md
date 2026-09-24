# Changelog

## [2.0.0](https://github.com/prefapp/tfm/compare/azure-managed-redis-v1.1.0...azure-managed-redis-v2.0.0) (2026-09-11)


### ⚠ BREAKING CHANGES

* **azure-redis-cache, azure-managed-redis:** var.private_endpoint (single, required object) is replaced by var.private_endpoints, a map(object) keyed by an arbitrary name, defaulting to {} (zero, one, or many endpoints). vnet, subnet_name, dns_private_zone_name and dns_private_zone_resource_group moved from module-level variables into each private_endpoints entry. Each entry can also set private_dns_zone_id to pass an already-resolved Private DNS Zone id (e.g. from another subscription, obtained in claims via a ref); when omitted, the zone is resolved in-subscription via dns_private_zone_name as before. Outputs private_endpoint_id/private_endpoint_private_ip are replaced by private_endpoint_ids/private_endpoint_private_ips maps.

### Features

* **azure-redis-cache, azure-managed-redis:** multiple private endpoints + cross-subscription DNS zones ([#1431](https://github.com/prefapp/tfm/issues/1431)) ([9005ebb](https://github.com/prefapp/tfm/commit/9005ebb7c60ae6937d616efb6783c542ca1f43e5))

## [1.1.0](https://github.com/prefapp/tfm/compare/azure-managed-redis-v1.0.1...azure-managed-redis-v1.1.0) (2026-09-01)


### Features

* add dns_private_zone_resource_group override ([#1421](https://github.com/prefapp/tfm/issues/1421)) ([2dbf08d](https://github.com/prefapp/tfm/commit/2dbf08d249cccd15103c82985fda4be412e49b58))

## [1.0.1](https://github.com/prefapp/tfm/compare/azure-managed-redis-v1.0.0...azure-managed-redis-v1.0.1) (2026-08-19)


### Bug Fixes

* add constraint version for azurerm 5.0 ([#1368](https://github.com/prefapp/tfm/issues/1368)) ([2b30f9b](https://github.com/prefapp/tfm/commit/2b30f9bed63b94aedf8f3af9736bf72bfd83073f))

## [1.0.0](https://github.com/prefapp/tfm/compare/azure-managed-redis-v0.1.0...azure-managed-redis-v1.0.0) (2026-06-29)


### ⚠ BREAKING CHANGES

* Add azure-managed-redis module ([#1309](https://github.com/prefapp/tfm/issues/1309))

### Miscellaneous Chores

* Add azure-managed-redis module ([#1309](https://github.com/prefapp/tfm/issues/1309)) ([5ab91ee](https://github.com/prefapp/tfm/commit/5ab91eec5e27c45e425d6b700b9d2b2254c4c09a))
