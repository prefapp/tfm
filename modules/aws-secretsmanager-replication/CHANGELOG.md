# Changelog

## [1.0.4](https://github.com/prefapp/tfm/compare/aws-secretsmanager-replication-v1.0.3...aws-secretsmanager-replication-v1.0.4) (2026-06-09)


### Bug Fixes

* **aws-secretsmanager-replication:** fix origin region name prefix ([#1293](https://github.com/prefapp/tfm/issues/1293)) ([a40eb4b](https://github.com/prefapp/tfm/commit/a40eb4bf93171a3a092d30c2292d259df12c51cc))

## [1.0.3](https://github.com/prefapp/tfm/compare/aws-secretsmanager-replication-v1.0.2...aws-secretsmanager-replication-v1.0.3) (2026-05-27)


### Bug Fixes

* capture InvalidParameterException on secret creation ([#1276](https://github.com/prefapp/tfm/issues/1276)) ([6d84eec](https://github.com/prefapp/tfm/commit/6d84eec1c118225c1bc2eb4afe2e069335463187))

## [1.0.2](https://github.com/prefapp/tfm/compare/aws-secretsmanager-replication-v1.0.1...aws-secretsmanager-replication-v1.0.2) (2026-05-20)


### Bug Fixes

* add retries for AWSCURRENT reading ([#1264](https://github.com/prefapp/tfm/issues/1264)) ([3730770](https://github.com/prefapp/tfm/commit/373077013843356c29eb381e5631cdf3866ce14c))

## [1.0.1](https://github.com/prefapp/tfm/compare/aws-secretsmanager-replication-v1.0.0...aws-secretsmanager-replication-v1.0.1) (2026-05-06)


### Bug Fixes

* capture ResourceExistsException and update instead of create ([#1248](https://github.com/prefapp/tfm/issues/1248)) ([db0788f](https://github.com/prefapp/tfm/commit/db0788ffa111b3911665dedcf04e55dd4c76eb07))

## [1.0.0](https://github.com/prefapp/tfm/compare/aws-secretsmanager-replication-v0.1.5...aws-secretsmanager-replication-v1.0.0) (2026-04-27)


### ⚠ BREAKING CHANGES

* update variables ([#1206](https://github.com/prefapp/tfm/issues/1206))

### Features

* update variables ([#1206](https://github.com/prefapp/tfm/issues/1206)) ([44b8d32](https://github.com/prefapp/tfm/commit/44b8d3204022803d16658708c1143b9583242c78))

## [0.1.5](https://github.com/prefapp/tfm/compare/aws-secretsmanager-replication-v0.1.4...aws-secretsmanager-replication-v0.1.5) (2026-03-24)


### Bug Fixes

* add region prefix name env var ([#1121](https://github.com/prefapp/tfm/issues/1121)) ([f168c3f](https://github.com/prefapp/tfm/commit/f168c3f12d3c54ee3f89b2e636f2785ef56d0148))

## [0.1.4](https://github.com/prefapp/tfm/compare/aws-secretsmanager-replication-v0.1.3...aws-secretsmanager-replication-v0.1.4) (2026-03-17)


### Bug Fixes

* tag and rename secrets on replication ([#984](https://github.com/prefapp/tfm/issues/984)) ([95bfaca](https://github.com/prefapp/tfm/commit/95bfaca348789448703bfd75a8381b25c88a2463))

## [0.1.3](https://github.com/prefapp/tfm/compare/aws-secretsmanager-replication-v0.1.2...aws-secretsmanager-replication-v0.1.3) (2026-02-18)


### Bug Fixes

* remove dependency ([#935](https://github.com/prefapp/tfm/issues/935)) ([59c11ea](https://github.com/prefapp/tfm/commit/59c11ea6337791c2b2e24628a0d0d2e688502fe9))

## [0.1.2](https://github.com/prefapp/tfm/compare/aws-secretsmanager-replication-v0.1.1...aws-secretsmanager-replication-v0.1.2) (2026-02-13)


### Bug Fixes

* cyclic check for cloutrail arn and name ([#933](https://github.com/prefapp/tfm/issues/933)) ([34bea76](https://github.com/prefapp/tfm/commit/34bea7646599b7ba53f531800c9b5250a6a20b45))

## [0.1.1](https://github.com/prefapp/tfm/compare/aws-secretsmanager-replication-v0.1.0...aws-secretsmanager-replication-v0.1.1) (2026-02-13)


### Bug Fixes

* break cyclic check for bucket policy ([#930](https://github.com/prefapp/tfm/issues/930)) ([fc59557](https://github.com/prefapp/tfm/commit/fc595578b44ff12967ca53ea22a513bca59ec02e))

## 0.1.0 (2026-02-13)


### Features

* **aws-secretsmanager-replication:** add new aws-secretsmanager-replication module ([#875](https://github.com/prefapp/tfm/issues/875)) ([78d83c2](https://github.com/prefapp/tfm/commit/78d83c29b8aa583c1c7760a0f78f7ef2d34e8c8c))
