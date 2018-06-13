# Use an official Drupal PHP runtime image as a parent image
FROM drupaldocker/php:7.1-cli

# Set the working directory to /php-ci
WORKDIR /php-ci

# Copy the current directory contents into the container at /php-ci
ADD . /php-ci

# Collect the components we need for this image
RUN apt-get update
RUN apt-get install -y ruby
RUN gem install circle-cli
RUN composer global require -n "hirak/prestissimo:^0.3"
RUN git clone https://github.com/pantheon-systems/terminus.git ~/terminus
RUN cd ~/terminus && git checkout 1.8.0 && composer install
RUN ln -s ~/terminus/bin/terminus /usr/local/bin/terminus
