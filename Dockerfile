# Use an official Drupal PHP runtime image as a parent image
FROM drupaldocker/php:7.4-cli-2.x

# Set the working directory to /php-ci
WORKDIR /php-ci

# Copy the current directory contents into the container at /php-ci
ADD . /php-ci

# Allow php to build phars
RUN echo 'phar.readonly=off' > /usr/local/etc/php/conf.d/phar.ini

# PCOV pecl module allows code coverage details without xdebug
RUN apk add --update --virtual mod-deps autoconf alpine-sdk ruby
RUN sudo pecl install pcov
RUN docker-php-ext-enable pcov

RUN curl -LO https://github.com/github/hub/releases/download/v2.10.0/hub-linux-amd64-2.10.0.tgz && tar xzvf hub-linux-amd64-2.10.0.tgz && ln -s /php-ci/hub-linux-amd64-2.10.0/bin/hub /usr/local/bin/hub
RUN gem install circle-cli
ENV COMPOSER_ALLOW_SUPERUSER 1
RUN git clone https://github.com/pantheon-systems/terminus.git ~/terminus
RUN cd ~/terminus && git checkout v3.0 && composer install
## temporary until v3.0 is public
RUN ln -s ~/terminus/bin/t3 /usr/local/bin/terminus
RUN ln -s ~/terminus/bin/t3 /usr/local/bin/t3

# Make a placeholder .bashrc
RUN echo '# Bash configuration' >> /root/.bashrc
