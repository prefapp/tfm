# Changelog

## [1.2.7](https://github.com/prefapp/tfm/compare/aws-eks-v1.2.6...aws-eks-v1.2.7) (2025-11-11)


### Bug Fixes

* **aws-eks:** remove extra depends-on from iam ([c7b1058](https://github.com/prefapp/tfm/commit/c7b105832f30a0bb844339b3d0971ede714eb5ab))

## [1.2.6](https://github.com/prefapp/tfm/compare/aws-eks-v1.2.5...aws-eks-v1.2.6) (2025-08-25)


### Bug Fixes

* aws-eks subnet_tags description ([#708](https://github.com/prefapp/tfm/issues/708)) ([f3b09fe](https://github.com/prefapp/tfm/commit/f3b09fea44d05aebf9598ca83b5b5b9637e464f1))

## [1.2.5](https://github.com/prefapp/tfm/compare/aws-eks-v1.2.4...aws-eks-v1.2.5) (2025-08-22)


### Bug Fixes

* aws-eks cluster addons default ([#706](https://github.com/prefapp/tfm/issues/706)) ([1f72b5b](https://github.com/prefapp/tfm/commit/1f72b5ba972b8023fdce973579aac11ada2dd70c))

## [1.2.4](https://github.com/prefapp/tfm/compare/aws-eks-v1.2.3...aws-eks-v1.2.4) (2025-08-22)


### Bug Fixes

* aws-eks addons output ([#704](https://github.com/prefapp/tfm/issues/704)) ([5a6108c](https://github.com/prefapp/tfm/commit/5a6108c11b3b5f10db830a7a842064a1ddb914d2))

## [1.2.3](https://github.com/prefapp/tfm/compare/aws-eks-v1.2.2...aws-eks-v1.2.3) (2025-08-20)


### Bug Fixes

* update aws eks alb policy ([#701](https://github.com/prefapp/tfm/issues/701)) ([e16a443](https://github.com/prefapp/tfm/commit/e16a443bd206ac76055f754404038a2e7fb38588))

## [1.2.2](https://github.com/prefapp/tfm/compare/aws-eks-v1.2.1...aws-eks-v1.2.2) (2025-07-23)


### Bug Fixes

* modify addons configuration_values structure ([#684](https://github.com/prefapp/tfm/issues/684)) ([d166716](https://github.com/prefapp/tfm/commit/d1667165b5339c512cf81fe37c4d92840339af45))

## [1.2.1](https://github.com/prefapp/tfm/compare/aws-eks-v1.2.0...aws-eks-v1.2.1) (2025-06-10)


### Bug Fixes

* add cluster_security_group_additional_rules ([#668](https://github.com/prefapp/tfm/issues/668)) ([4de1b06](https://github.com/prefapp/tfm/commit/4de1b064359590d9a0a21e2098f940a418fcd6ae))
* aws-eks subnet vpc tags ([#665](https://github.com/prefapp/tfm/issues/665)) ([4381b2a](https://github.com/prefapp/tfm/commit/4381b2acf036d2ced8af795b47302fa4c782796a))

## [1.2.0](https://github.com/prefapp/tfm/compare/aws-eks-v1.1.1...aws-eks-v1.2.0) (2025-05-28)


### Features

* Add VPC selection based on tag ([abbd24b](https://github.com/prefapp/tfm/commit/abbd24bf58c022f565f03a166a15978e3358ed68))

## [1.1.1](https://github.com/prefapp/tfm/compare/aws-eks-v1.1.0...aws-eks-v1.1.1) (2025-04-24)


### Bug Fixes

* Update role_assignment.tf ([7592841](https://github.com/prefapp/tfm/commit/75928419415d74de12d2d38a602df7aa703c860e))

## [1.1.0](https://github.com/prefapp/tfm/compare/aws-eks-v1.0.5...aws-eks-v1.1.0) (2025-04-24)


### Features

* Update README.md ([a7dfb55](https://github.com/prefapp/tfm/commit/a7dfb55b83447cf3ef08d168ab756e791f322e7a))

## [1.0.5](https://github.com/prefapp/tfm/compare/aws-eks-v1.0.4...aws-eks-v1.0.5) (2025-04-01)


### Bug Fixes

* update aws-eks external-dns policy ([#493](https://github.com/prefapp/tfm/issues/493)) ([3ca2c98](https://github.com/prefapp/tfm/commit/3ca2c988b78ae877ba0a1f7b18e9555b22a37866))

## [1.0.4](https://github.com/prefapp/tfm/compare/aws-eks-v1.0.3...aws-eks-v1.0.4) (2025-03-27)


### Bug Fixes

* update iam alb policy ([#487](https://github.com/prefapp/tfm/issues/487)) ([acaf02d](https://github.com/prefapp/tfm/commit/acaf02d0817e0f2e4f8060a1b2336238617364de))

## [1.0.3](https://github.com/prefapp/tfm/compare/aws-eks-v1.0.2...aws-eks-v1.0.3) (2025-03-19)


### Bug Fixes

* desired_size field ([#483](https://github.com/prefapp/tfm/issues/483)) ([239d2c0](https://github.com/prefapp/tfm/commit/239d2c0ad65e071eeb989fa3a60731bbcf1fb4a4))

## [1.0.2](https://github.com/prefapp/tfm/compare/aws-eks-v1.0.1...aws-eks-v1.0.2) (2025-03-19)


### Bug Fixes

* delete manage_aws_auth_configmap field ([#479](https://github.com/prefapp/tfm/issues/479)) ([13f000b](https://github.com/prefapp/tfm/commit/13f000b0bb881e53eccf91355c2dfc8d39447b2c))

## [1.0.1](https://github.com/prefapp/tfm/compare/aws-eks-v1.0.0...aws-eks-v1.0.1) (2025-03-18)


### Bug Fixes

* redundant enable_prefix_delegation ([#476](https://github.com/prefapp/tfm/issues/476)) ([e0ecc52](https://github.com/prefapp/tfm/commit/e0ecc5207dcb45fc114c6424513e344e120c4215))

## [1.0.0](https://github.com/prefapp/tfm/compare/aws-eks-v0.4.0...aws-eks-v1.0.0) (2025-03-13)


### ⚠ BREAKING CHANGES

* create_iam_role, iam_role_arn, cluster_addons and access_entries

### Features

* create_iam_role, iam_role_arn, cluster_addons and access_entries ([42d1495](https://github.com/prefapp/tfm/commit/42d14955944256c2e68bb0ab00ebcbfa432564fd))

## [0.4.0](https://github.com/prefapp/tfm/compare/aws-eks-v0.3.0...aws-eks-v0.4.0) (2025-01-27)


### Features

* update alb policy ([#419](https://github.com/prefapp/tfm/issues/419)) ([1c28f68](https://github.com/prefapp/tfm/commit/1c28f68674ff4b49d0f5f6dbbadc7a2fc2501ba4))
* update eks module to v20.33.1 ([1c0abc0](https://github.com/prefapp/tfm/commit/1c0abc014a3e89bf3de3ec780a7871d6c4b7ddab))

## [0.3.0](https://github.com/prefapp/tfm/compare/aws-eks-v0.2.0...aws-eks-v0.3.0) (2024-02-19)


### Features

* Update alb policy to versions 2.7.0 aws-load-balancer-controller ([#81](https://github.com/prefapp/tfm/issues/81)) ([2d237e9](https://github.com/prefapp/tfm/commit/2d237e9c4d1d0dbbc03ed9bf08d153faf360147b))

## [0.2.0](https://github.com/prefapp/tfm/compare/aws-eks-v0.1.0...aws-eks-v0.2.0) (2023-12-19)


### Features

* Update README.md ([#62](https://github.com/prefapp/tfm/issues/62)) ([302440a](https://github.com/prefapp/tfm/commit/302440a79ea0e4883b6583e3540deac7bac6c307))

## 0.1.0 (2023-11-29)


### ⚠ BREAKING CHANGES

* update aws eks doc ([#56](https://github.com/prefapp/tfm/issues/56))
* add eks module ([#51](https://github.com/prefapp/tfm/issues/51))

### Features

* add eks module ([#51](https://github.com/prefapp/tfm/issues/51)) ([549216c](https://github.com/prefapp/tfm/commit/549216ccb21376f8c029c746d70c4f9170c626da))
* Deploy release ([#37](https://github.com/prefapp/tfm/issues/37)) ([fba2614](https://github.com/prefapp/tfm/commit/fba2614fb284cf9d960be53c7c123ceaf08cecfa))
* update aws eks doc ([#56](https://github.com/prefapp/tfm/issues/56)) ([010bc3e](https://github.com/prefapp/tfm/commit/010bc3ef855c39dc58d26a7c103368f660b8d061))
