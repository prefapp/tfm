# Changelog

## [1.9.3](https://github.com/prefapp/tfm/compare/azure-aks-v1.9.2...azure-aks-v1.9.3) (2025-12-03)


### Bug Fixes

* update module and tags ([#760](https://github.com/prefapp/tfm/issues/760)) ([daa987b](https://github.com/prefapp/tfm/commit/daa987b6d0d3d31233a8ca2e76f9580ca54449af))

## [1.9.2](https://github.com/prefapp/tfm/compare/azure-aks-v1.9.1...azure-aks-v1.9.2) (2025-04-25)


### Bug Fixes

* Fix kubelet_identity_object_id output ([#632](https://github.com/prefapp/tfm/issues/632)) ([a99a854](https://github.com/prefapp/tfm/commit/a99a8542d34be66e6387a6d56d34d0672a6b21a9))

## [1.9.1](https://github.com/prefapp/tfm/compare/azure-aks-v1.9.0...azure-aks-v1.9.1) (2025-04-24)


### Bug Fixes

* Update role_assignment.tf ([7592841](https://github.com/prefapp/tfm/commit/75928419415d74de12d2d38a602df7aa703c860e))

## [1.9.0](https://github.com/prefapp/tfm/compare/azure-aks-v1.8.1...azure-aks-v1.9.0) (2025-04-24)


### Features

* Update README.md ([a7dfb55](https://github.com/prefapp/tfm/commit/a7dfb55b83447cf3ef08d168ab756e791f322e7a))

## [1.8.1](https://github.com/prefapp/tfm/compare/azure-aks-v1.8.0...azure-aks-v1.8.1) (2025-04-24)


### Bug Fixes

* Fix kubelet_identity_client_id output ([#511](https://github.com/prefapp/tfm/issues/511)) ([5277b83](https://github.com/prefapp/tfm/commit/5277b8306c1ae656f9a193ebce814e89733e5229))

## [1.8.0](https://github.com/prefapp/tfm/compare/azure-aks-v1.7.1...azure-aks-v1.8.0) (2024-10-17)


### Features

* Only stetic changes ([#308](https://github.com/prefapp/tfm/issues/308)) ([4044b0d](https://github.com/prefapp/tfm/commit/4044b0dd4d9334b9aa97a30dd8f8d0ebd627335a))

## [1.7.1](https://github.com/prefapp/tfm/compare/azure-aks-v1.7.0...azure-aks-v1.7.1) (2024-10-14)


### Bug Fixes

* Fix (remove) host AKS output ([#299](https://github.com/prefapp/tfm/issues/299)) ([3cf162d](https://github.com/prefapp/tfm/commit/3cf162da7f75dffc5a860a75f5ac00d74ec7afc7))

## [1.7.0](https://github.com/prefapp/tfm/compare/azure-aks-v1.6.0...azure-aks-v1.7.0) (2024-10-14)


### Features

* Add more AKS module outputs ([#297](https://github.com/prefapp/tfm/issues/297)) ([5e634d4](https://github.com/prefapp/tfm/commit/5e634d4f368f97e246a23735cd257dd763db41c6))

## [1.6.0](https://github.com/prefapp/tfm/compare/azure-aks-v1.5.2...azure-aks-v1.6.0) (2024-09-23)


### Features

* Add upgrade_settings into AKS module ([#161](https://github.com/prefapp/tfm/issues/161)) ([f9692c7](https://github.com/prefapp/tfm/commit/f9692c7a3f3cec83a7695b6db914451da689ae8f))
* Deploy release ([#127](https://github.com/prefapp/tfm/issues/127)) ([2d5c56b](https://github.com/prefapp/tfm/commit/2d5c56bcd9f1443136a9a4c34e19a3874dcf7ea5))

## [1.5.2](https://github.com/prefapp/tfm/compare/azure-aks-v1.5.1...azure-aks-v1.5.2) (2024-08-01)


### Bug Fixes

* add cluster_issuer output to the aks module ([#113](https://github.com/prefapp/tfm/issues/113)) ([848f3f4](https://github.com/prefapp/tfm/commit/848f3f4155584a28d56a19d2a3acacda7dc700f0))

## [1.5.1](https://github.com/prefapp/tfm/compare/azure-aks-v1.5.0...azure-aks-v1.5.1) (2024-08-01)


### Bug Fixes

* Set some variables ([#111](https://github.com/prefapp/tfm/issues/111)) ([f1613b0](https://github.com/prefapp/tfm/commit/f1613b086cb90df06f15bf2523ac155e8149777a))

## [1.5.0](https://github.com/prefapp/tfm/compare/azure-aks-v1.4.1...azure-aks-v1.5.0) (2024-07-31)


### Features

* Change aks module to use official aks module ([#108](https://github.com/prefapp/tfm/issues/108)) ([93095a4](https://github.com/prefapp/tfm/commit/93095a48bc9f9220e2da8f993891a1d587795c1e))

## [1.4.1](https://github.com/prefapp/tfm/compare/azure-aks-v1.4.0...azure-aks-v1.4.1) (2024-01-25)


### Bug Fixes

* Revert ([#74](https://github.com/prefapp/tfm/issues/74)) ([926f515](https://github.com/prefapp/tfm/commit/926f515986bbcfa7951a6aba2e92dd23900e4aac))

## [1.4.0](https://github.com/prefapp/tfm/compare/azure-aks-v1.3.0...azure-aks-v1.4.0) (2024-01-25)


### Features

* Skip certain tags via lifecycle on some modules ([#72](https://github.com/prefapp/tfm/issues/72)) ([0e7211b](https://github.com/prefapp/tfm/commit/0e7211b7a36efe9cdbdbf6a751c198c0f2216ae5))

## [1.3.0](https://github.com/prefapp/tfm/compare/azure-aks-v1.2.0...azure-aks-v1.3.0) (2024-01-25)


### Features

* Set a null some network_profile variables ([#69](https://github.com/prefapp/tfm/issues/69)) ([1bdb182](https://github.com/prefapp/tfm/commit/1bdb182fd2a41ba3ead37e1670c50e37846a2777))

## [1.2.0](https://github.com/prefapp/tfm/compare/azure-aks-v1.1.0...azure-aks-v1.2.0) (2023-12-19)


### Features

* Update README.md ([#62](https://github.com/prefapp/tfm/issues/62)) ([302440a](https://github.com/prefapp/tfm/commit/302440a79ea0e4883b6583e3540deac7bac6c307))

## [1.1.0](https://github.com/prefapp/tfm/compare/azure-aks-v1.0.0...azure-aks-v1.1.0) (2023-12-15)


### Features

* Deploy release ([#37](https://github.com/prefapp/tfm/issues/37)) ([fba2614](https://github.com/prefapp/tfm/commit/fba2614fb284cf9d960be53c7c123ceaf08cecfa))
