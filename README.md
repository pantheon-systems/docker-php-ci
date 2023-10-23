# Docker PHP CI

[![docker pull quay.io/pantheon-public/php-ci](https://img.shields.io/badge/image-quay-blue.svg)](https://quay.io/repository/pantheon-public/php-ci)

This is the source Dockerfile for the [pantheon-public/php-ci](https://quay.io/repository/pantheon-public/php-ci) docker image.

## Usage
In CircleCI 2.0/github actions
```
  docker:
    - image: quay.io/pantheon-public/php-ci:v7.4
```
## Image Contents

- [PHP 7.4](https://github.com/drupal-docker/php/tree/master/7.4)
- [Terminus](https://github.com/pantheon-systems/terminus)
- [circle-cli](https://github.com/circle-cli/circle-cli) test tool

## Branches
- 4.x: Unsupported, some outdated versions, may still receive updates. Used for build-tools plugin testing.
- v8.2: Unsupported, some outdated versions, may still receive updates.
- Any other branch: Unsupported, unmaintained.

Note that this image does not include any Terminus extensions. See [build-tools-ci image](https://github.com/pantheon-systems/docker-build-tools-ci) for a more complete Docker image pre-populated with a number of useful Terminus plugins. To test a Terminus plugin, use [pantheon-public/terminus-plugin-test](https://quay.io/repository/pantheon-public/terminus-plugin-test).

