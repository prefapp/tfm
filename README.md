# 🚀 Release Please Versioning Management

Check action doc https://github.com/googleapis/release-please-action

This repo is managed by Release Please. This is an automated Semver control System.

## How release please works

Release Please automates CHANGELOG generation, the creation of GitHub releases,
and version bumps for your projects. Release Please does so by parsing your
git history, looking for [Conventional Commit messages](https://www.conventionalcommits.org/),
and creating release PRs.

### How should I write my commits?

Release Please assumes you are using [Conventional Commit messages](https://www.conventionalcommits.org/).

The most important prefixes you should have in mind are:

* `fix:` which represents bug fixes, and correlates to a [SemVer](https://semver.org/)
  patch.
* `feat:` which represents a new feature, and correlates to a SemVer minor.
* `feat!:`,  or `fix!:`, `refactor!:`, etc., which represent a breaking change
  (indicated by the `!`) and will result in a SemVer major.

### What's a Release PR?

Rather than continuously releasing what's landed to your default branch,
release-please maintains Release PRs:

These Release PRs are kept up-to-date as additional work is merged. When you're
ready to tag a release, simply merge the release PR.

### Troubleshooting

If you merge accidentaly a conventional commit, you can move the commits starting analysis to another commit following this guide https://github.com/googleapis/release-please/blob/288949797c6bfd95e08d74a6222e7d26e0020a7c/docs/manifest-releaser.md?plain=1#L140-L153
