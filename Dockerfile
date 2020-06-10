# Use an official Drupal PHP runtime image as a parent image
FROM drupaldocker/php:7.3-cli-2.x

# Set the working directory to /php-ci
WORKDIR /php-ci

# Copy the current directory contents into the container at /php-ci
ADD . /php-ci

# Allow php to build phars
RUN echo 'phar.readonly=off' > /usr/local/etc/php/conf.d/phar.ini

# Collect the components we need for this image
RUN apk add --no-cache --virtual ruby vim bash

RUN curl -LO https://github.com/github/hub/releases/download/v2.10.0/hub-linux-amd64-2.10.0.tgz && tar xzvf hub-linux-amd64-2.10.0.tgz && ln -s /php-ci/hub-linux-amd64-2.10.0/bin/hub /usr/local/bin/hub

RUN curl -fLSs https://raw.githubusercontent.com/CircleCI-Public/circleci-cli/master/install.sh | DESTDIR=/usr/local/bin /bin/bash

RUN composer global require -n "hirak/prestissimo:^0.3"

# Add Terminus
RUN curl -O https://raw.githubusercontent.com/pantheon-systems/terminus-installer/master/builds/installer.phar && php installer.phar install

# Add Terminus plugins
env TERMINUS_PLUGINS_DIR /root/.terminus/plugins
RUN mkdir -p /root/.terminus/plugins
RUN composer -n create-project --no-dev -d /root/.terminus/plugins pantheon-systems/terminus-clu-plugin:^1.0.1

# Make a placeholder .bashrc
RUN echo '# Bash configuration' >> /root/.bashrc
