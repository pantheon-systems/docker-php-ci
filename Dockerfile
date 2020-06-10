# Use an official Drupal PHP runtime image as a parent image
FROM drupaldocker/php:7.3-cli-2.x

# Set the working directory to /php-ci
WORKDIR /php-ci

# Copy the current directory contents into the container at /php-ci
ADD . /php-ci

# Allow php to build phars
RUN echo 'phar.readonly=off' > /usr/local/etc/php/conf.d/phar.ini

# Collect the components we need for this image
RUN apk add --no-cache --virtual ruby vim

RUN curl -LO https://github.com/github/hub/releases/download/v2.10.0/hub-linux-amd64-2.10.0.tgz && tar xzvf hub-linux-amd64-2.10.0.tgz && ln -s /php-ci/hub-linux-amd64-2.10.0/bin/hub /usr/local/bin/hub

# CircleCI installer doesn't work with /bin/sh, installing bash with apk problematic0
# RUN curl -fLSs https://raw.githubusercontent.com/CircleCI-Public/circleci-cli/master/install.sh | DESTDIR=/usr/local/bin /bin/bash

# Install a specific version of the CircleCI cli as a workaround for ^^
RUN curl -LO https://github.com/CircleCI-Public/circleci-cli/releases/download/v0.1.7971/circleci-cli_0.1.7971_linux_amd64.tar.gz && tar xzvf circleci-cli_0.1.7971_linux_amd64.tar.gz && ln -s /php-ci/circleci-cli_0.1.7971_linux_amd64/circleci /usr/local/bin

RUN composer global require -n "hirak/prestissimo:^0.3"

# Add Terminus
RUN curl -O https://raw.githubusercontent.com/pantheon-systems/terminus-installer/master/builds/installer.phar && php installer.phar install

# Add Terminus plugins
env TERMINUS_PLUGINS_DIR /root/.terminus/plugins
RUN mkdir -p /root/.terminus/plugins
RUN composer -n create-project --no-dev -d /root/.terminus/plugins pantheon-systems/terminus-clu-plugin:^1.0.1

# Make a placeholder .bashrc
RUN echo '# Bash configuration' >> /root/.bashrc
