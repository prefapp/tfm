# Changelog

## [1.0.0](https://github.com/prefapp/tfm/compare/azure-redis-cache-v0.3.0...azure-redis-cache-v1.0.0) (2026-09-11)


### ⚠ BREAKING CHANGES

* **azure-redis-cache, azure-managed-redis:** var.private_endpoint (single, required object) is replaced by var.private_endpoints, a map(object) keyed by an arbitrary name, defaulting to {} (zero, one, or many endpoints). vnet, subnet_name, dns_private_zone_name and dns_private_zone_resource_group moved from module-level variables into each private_endpoints entry. Each entry can also set private_dns_zone_id to pass an already-resolved Private DNS Zone id (e.g. from another subscription, obtained in claims via a ref); when omitted, the zone is resolved in-subscription via dns_private_zone_name as before. Outputs private_endpoint_id/private_endpoint_private_ip are replaced by private_endpoint_ids/private_endpoint_private_ips maps.

### Features

* **azure-redis-cache, azure-managed-redis:** multiple private endpoints + cross-subscription DNS zones ([#1431](https://github.com/prefapp/tfm/issues/1431)) ([9005ebb](https://github.com/prefapp/tfm/commit/9005ebb7c60ae6937d616efb6783c542ca1f43e5))

## [0.3.0](https://github.com/prefapp/tfm/compare/azure-redis-cache-v0.2.3...azure-redis-cache-v0.3.0) (2026-09-01)


### Features

* add dns_private_zone_resource_group override ([#1420](https://github.com/prefapp/tfm/issues/1420)) ([b04363f](https://github.com/prefapp/tfm/commit/b04363f37aa92379a1295d86c63f1f045e56f641))

## [0.2.3](https://github.com/prefapp/tfm/compare/azure-redis-cache-v0.2.2...azure-redis-cache-v0.2.3) (2026-08-19)


### Bug Fixes

* add constraint version for azurerm 5.0 ([#1368](https://github.com/prefapp/tfm/issues/1368)) ([2b30f9b](https://github.com/prefapp/tfm/commit/2b30f9bed63b94aedf8f3af9736bf72bfd83073f))

## [0.2.2](https://github.com/prefapp/tfm/compare/azure-redis-cache-v0.2.1...azure-redis-cache-v0.2.2) (2025-05-05)


### Bug Fixes

* move resources previously created ([#643](https://github.com/prefapp/tfm/issues/643)) ([8a46be8](https://github.com/prefapp/tfm/commit/8a46be82953952f147cb3ae228cacb0703c4c63a))

## [0.2.1](https://github.com/prefapp/tfm/compare/azure-redis-cache-v0.2.0...azure-redis-cache-v0.2.1) (2025-04-24)


### Bug Fixes

* Update role_assignment.tf ([7592841](https://github.com/prefapp/tfm/commit/75928419415d74de12d2d38a602df7aa703c860e))

## [0.2.0](https://github.com/prefapp/tfm/compare/azure-redis-cache-v0.1.0...azure-redis-cache-v0.2.0) (2025-04-24)


### Features

* Update README.md ([a7dfb55](https://github.com/prefapp/tfm/commit/a7dfb55b83447cf3ef08d168ab756e791f322e7a))

## [0.2.0](https://github.com/prefapp/tfm/compare/azure-redis-cache-v0.1.0...azure-redis-cache-v0.2.0) (2025-04-24)


### Features

* Update README.md ([a7dfb55](https://github.com/prefapp/tfm/commit/a7dfb55b83447cf3ef08d168ab756e791f322e7a))

## 0.1.0 (2025-03-21)


### ⚠ BREAKING CHANGES

* Azure redis-cache module ([#475](https://github.com/prefapp/tfm/issues/475))

### Features

* Azure redis-cache module ([#475](https://github.com/prefapp/tfm/issues/475)) ([f04b881](https://github.com/prefapp/tfm/commit/f04b881a69c032d40e628810b57e170aa0b67e6e))
