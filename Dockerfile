# Use an official Drupal PHP runtime image as a parent image
FROM php:7.4-cli
ARG PHP_VERSION=7.4
ARG REPO_NAME=pantheon-systems/docker-php-ci
ARG VCS_REF
ARG ENV
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV LANG en_US.utf8
ENV DEBIAN_FRONTEND=noninteractive
ENV ACCEPT_EULA Y
ENV CODELINT_COMMAND="~/.composer/vendor/bin/phpcs --colors --standard=Drupal --extensions='php,module,inc,install,test,profile,theme,js,css,info,txt,md' -v "
ENV CODELINT="\n\nalias drupalcs=\"${CODELINT_COMMAND}\"\n"
ENV CODELINT_FIX_COMMAND="phpcbf --standard=Drupal --extensions='php,module,inc,install,test,profile,theme,css,info,txt,md' -v "
ENV CODELINT_FIX="\nalias drupalcbf=\"${CODELINT_FIX_COMMAND}\"\n"


LABEL org.label-schema.vendor="pantheon" \
  org.label-schema.name=$REPO_NAME \
  org.label-schema.description="CI Integrations for Pantheon" \
  org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.version=$PHP_VERSION \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.vcs-url="https://github.com/$REPO_NAME" \
  org.label-schema.usage="https://github.com/$REPO_NAME/blob/master/README.md#usage" \
  org.label-schema.schema-version="1.0"

# Set the working directory to /php-ci
RUN apt-get update -y --fix-missing && apt-get install -y \
      gnupg2

WORKDIR /tmp
RUN curl -sS -o - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN echo "deb [arch=amd64]  http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN update-ca-certificates --verbose --fresh
RUN mkdir -p /usr/share/man/man1

RUN apt-get update -y --fix-missing && apt-get install -y \
      supervisor \
      curl \
      apt-transport-https \
      cron \
      vim \
      procps \
      apt-utils \
      libfreetype6-dev \
      libjpeg62-turbo-dev \
      libpng-dev \
      imagemagick \
      procps \
      awscli \
      syncthing \
      supervisor \
      apt-utils \
      nfs-common \
      icu-devtools \
      libicu-dev \
      libxml2-dev \
      libcairo2 \
      libsodium-dev \
      libjpeg-dev \
      libgd-dev \
      libpng-dev \
      libyaml-dev \
      libcairo2-dev \
      libgss3 \
      g++ \
      gcc \
      git \
      libpcre3-dev \
      wget \
      default-mysql-client \
      zip \
      libzip-dev \
      redis-tools \
      xvfb \
      libgconf-2-4 \
      libxi6 \
      unzip \
      google-chrome-stable \
      gvfs \
      pcscd \
      locales \
      software-properties-common \
      gnupg \
      re2c \
      lcov \
      unixodbc \
      unixodbc-dev \
      odbcinst \
      msodbcsql17 \
      mssql-tools \
      pv \
      rsync \
      bash-completion \
      ruby \
      bash

# Libraries for Imagemagick
RUN apt-get update && apt-get install -y libmagick++-dev libmagickcore-dev libmagickwand-6-headers libmagickwand-dev --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Allow php to build phars
RUN echo 'phar.readonly=off' > /usr/local/etc/php/conf.d/phar.ini

RUN apt-get update -y --fix-missing && apt-get -yf install   default-jre-headless default-jdk-headless default-jre default-jdk
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
RUN chmod +x ~/.*
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
RUN locale-gen en_US.UTF-8
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

# PCOV pecl module allows code coverage details without xdebug

RUN wget https://chromedriver.storage.googleapis.com/2.41/chromedriver_linux64.zip
RUN unzip chromedriver_linux64.zip
RUN mv chromedriver /usr/bin/chromedriver
RUN chown root:root /usr/bin/chromedriver
RUN chmod +x /usr/bin/chromedriver
RUN wget https://selenium-release.storage.googleapis.com/3.9/selenium-server-standalone-3.9.1.jar
RUN mv selenium-server-standalone-3.9.1.jar /opt/selenium-server-standalone.jar
RUN curl -fLSs https://circle.ci/cli | bash

RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -
RUN apt-get install -y nodejs
RUN npm install -g npm
RUN npm install -g yarn
RUN npm install -g gulp-cli
RUN npm install -g typescript
RUN npm install -g eslint

ADD https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem  /etc/ssl/certs/rds-combined-ca-bundle.pem
RUN chmod 755 /etc/ssl/certs/rds-combined-ca-bundle.pem

RUN printf "\n\nexport COMPOSER_ALLOW_SUPERUSER=1\n" >> $HOME/.bash_profile
RUN curl --silent --show-error https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN export PATH="/var/www/vendor/bin:/root/.composer/global:./bin:$(composer config -g home)/vendor/bin:$PATH"
ENV PATH /var/www/vendor/bin:$PATH:/root/.composer/vendor/bin
RUN composer selfupdate --2

# PHP ${PHP_VERSION}
RUN docker-php-ext-install -j$(nproc) intl
RUN docker-php-ext-install -j$(nproc) iconv
RUN docker-php-ext-install -j$(nproc) pcntl
RUN docker-php-ext-install -j$(nproc) soap
RUN docker-php-ext-install -j$(nproc) xml
RUN docker-php-ext-install -j$(nproc) zip
RUN docker-php-ext-install -j$(nproc) pdo
RUN docker-php-ext-install -j$(nproc) pdo_mysql
RUN docker-php-ext-install -j$(nproc) opcache
RUN git clone https://github.com/Imagick/imagick /usr/src/php/ext/imagick \
  && cd /usr/src/php/ext/imagick \
  && phpize && ./configure && make \
  && docker-php-ext-install imagick

RUN pecl bundle -d /usr/src/php/ext yaml \
    && rm /usr/src/php/ext/yaml-*.tgz \
    && docker-php-ext-install yaml

RUN pecl bundle -d /usr/src/php/ext redis \
    && rm /usr/src/php/ext/redis-*.tgz \
    && docker-php-ext-install redis

RUN pecl bundle -d /usr/src/php/ext pcov \
    && rm /usr/src/php/ext/pcov-*.tgz \
    && docker-php-ext-install pcov

RUN pecl bundle -d /usr/src/php/ext uploadprogress \
    && rm /usr/src/php/ext/uploadprogress-*.tgz \
    && docker-php-ext-install uploadprogress

COPY php/overrides.ini /usr/local/etc/php-fpm.d
COPY php/php.ini /usr/local/etc/php
COPY php/overrides.ini /usr/local/etc/php/conf.d

RUN pecl config-set php_ini /usr/local/etc/php/php.ini && \
        pear config-set php_ini /usr/local/etc/php/php.ini && \
        pecl channel-update pecl.php.net



RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd
# as of 2019-AUG-06 drupal redis module didn't work with redis 5


## Install MSSQL php extension
RUN pecl bundle -d /usr/src/php/ext sqlsrv \
    && rm /usr/src/php/ext/sqlsrv-*.tgz \
    && docker-php-ext-install sqlsrv
RUN pecl bundle -d /usr/src/php/ext pdo_sqlsrv \
    && rm /usr/src/php/ext/pdo_sqlsrv-*.tgz \
    && docker-php-ext-install pdo_sqlsrv

RUN mkdir -p /opt

WORKDIR /opt
RUN git clone -b v3.0 https://github.com/pantheon-systems/terminus.git ./terminus
RUN cd /opt/terminus && composer install \
  && composer phar:build && composer phar:install && \
  ln -s /usr/local/bin/t3 /usr/local/bin/terminus

RUN curl -LO https://github.com/github/hub/releases/download/v2.10.0/hub-linux-amd64-2.10.0.tgz && tar xzvf hub-linux-amd64-2.10.0.tgz && ln -s /php-ci/hub-linux-amd64-2.10.0/bin/hub /usr/local/bin/hub
RUN gem install circle-cli
# Make a placeholder .bashrc
RUN echo '# Bash configuration' >> /root/.bashrc
RUN rm -Rf /usr/src/*
RUN echo ${CODELINT} >> /root/.bashrc
RUN echo ${CODELINT_FIX} >> /root/.bashrc
RUN mkdir /php-cgi

WORKDIR /php-cgi

ENTRYPOINT [ "/usr/local/bin/docker-php-entrypoint" ]
