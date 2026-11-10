# Docker PHP CI

[![docker pull quay.io/pantheon-public/php-ci](https://img.shields.io/badge/image-quay-blue.svg)](https://quay.io/repository/pantheon-public/php-ci)

This is the source Dockerfile for the [pantheon-public/php-ci](https://quay.io/repository/pantheon-public/php-ci) docker image.

## Usage
In CircleCI 2.0:
```
  docker:
    - image: quay.io/pantheon-public/php-ci:4.x
```
## Deployment

There is no GitHub Actions pipeline: a Quay build trigger builds every pushed branch into a tag of the
same name (`4.x` also becomes `latest`), and consumers get it on their next CI run. Terminus's release
workflow runs in `php-ci:v8.2`. See [DEPLOYMENT.md](DEPLOYMENT.md).

## Rollback

- **When:** a newly built tag breaks a consumer's CI (for `v8.2`, Terminus's build or release jobs).
- **Recover:** within 14 days, restore the tag to its previous manifest in Quay; a revert-and-rebuild
  won't reproduce the old image.
- **Verify:** the tag's digest matches the one captured before the push.
- **Who:** `#ask-hosting` (developer-experience).

Details: [DEPLOYMENT.md](DEPLOYMENT.md#rollback).

## Image Contents

- [PHP 7.3](https://github.com/drupal-docker/php/tree/master/7.3)
- [Terminus](https://github.com/pantheon-systems/terminus)
- [circle-cli](https://github.com/circle-cli/circle-cli) test tool

## Branches
- 4.x: Unsupported, some outdated versions, may still receive updates. Used for build-tools plugin testing.
- v8.2: Unsupported, some outdated versions, may still receive updates.
- Any other branch: Unsupported, unmaintained.

Note that this image does not include any Terminus extensions. See [build-tools-ci image](https://github.com/pantheon-systems/docker-build-tools-ci) for a more complete Docker image pre-populated with a number of useful Terminus plugins. To test a Terminus plugin, use [pantheon-public/terminus-plugin-test](https://quay.io/repository/pantheon-public/terminus-plugin-test).

