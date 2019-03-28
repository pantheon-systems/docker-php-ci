# Use an official Drupal PHP runtime image as a parent image
FROM drupaldocker/php:7.2-cli

# Set the working directory to /php-ci
WORKDIR /php-ci

# Copy the current directory contents into the container at /php-ci
ADD . /php-ci

# Allow php to build phars
RUN echo 'phar.readonly=off' > /usr/local/etc/php/conf.d/phar.ini

# Collect the components we need for this image
RUN apt-get update
RUN apt-get install -y ruby

RUN curl -LO https://github.com/github/hub/releases/download/v2.10.0/hub-linux-amd64-2.10.0.tgz && tar xzvf hub-linux-amd64-2.10.0.tgz && ln -s /php-ci/hub-linux-amd64-2.10.0/bin/hub /usr/local/bin/hub

RUN gem install circle-cli
RUN composer global require -n "hirak/prestissimo:^0.3"
RUN git clone https://github.com/pantheon-systems/terminus.git ~/terminus
RUN cd ~/terminus && git checkout 2.0.0 && composer install
RUN ln -s ~/terminus/bin/terminus /usr/local/bin/terminus

# Make a placeholder .bashrc
RUN echo '# Bash configuration' >> /root/.bashrc
