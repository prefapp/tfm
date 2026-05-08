# Changelog

## [UNRELEASED]

### Breaking
* Remove deprecated `pages` block from github_repository.this and variables. Pages configuration is now managed with github_repository_pages resource (see #1255 and provider docs).

### Migration
* If you were passing pages parameters in the config, use github_repository_pages resource with the same branch/path/cname/buildType fields.


## [0.3.0](https://github.com/prefapp/tfm/compare/github-repo-v0.2.0...github-repo-v0.3.0) (2026-05-07)


### Features

* add support for pages ([#1196](https://github.com/prefapp/tfm/issues/1196)) ([4efe491](https://github.com/prefapp/tfm/commit/4efe491b40c60823ac644482385dd1917ef12392))

## [0.2.0](https://github.com/prefapp/tfm/compare/github-repo-v0.1.0...github-repo-v0.2.0) (2026-04-30)


### Features

* add support for repo labels ([#1211](https://github.com/prefapp/tfm/issues/1211)) ([affd301](https://github.com/prefapp/tfm/commit/affd3011e016241cee9db754c65ab972cfc469a6))

## 0.1.0 (2026-03-31)


### Features

* add gh-repo initial implementation ([#968](https://github.com/prefapp/tfm/issues/968)) ([7328a01](https://github.com/prefapp/tfm/commit/7328a01f70b5e45ba8e802f87481cf40e870a82b))
