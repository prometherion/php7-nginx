FROM php:7.1.1-fpm

MAINTAINER prometherion <dario.tranchitella@starteed.com>

EXPOSE 80

WORKDIR /var/www

#
# Updating repositories
#
RUN apt-get update

#
# Installing NGINX with custom configuration file: optimized for PHP-FPM and already non-daemoned
#
RUN apt-get install nginx -y
RUN rm -rf /etc/nginx/sites-*
ADD conf/default.conf /etc/nginx/conf.d/default.conf
ADD conf/nginx.conf /etc/nginx/nginx.conf

#
# Installing Composer
#
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
	php composer-setup.php --install-dir=/usr/bin --filename=composer && \
	php -r "unlink('composer-setup.php');"

#
# Installing Supervisor
#
RUN apt-get install supervisor -y
ADD conf/supervisor.conf /etc/supervisor/conf.d/start.conf

#
# Installing Git and Zip/Unzip for Composer speed up
#
RUN apt-get install -y git zip unzip zlib1g-dev
RUN docker-php-ext-install zip

#
# Cleaning up apt cache
#
RUN rm -rf /var/lib/apt/lists/*

#
# Defining base environment file
#
ENV ENV_FILE=.env

#
# PHP-FPM environment variables for performance tuning
#
ENV LISTEN=127.0.0.1:9000
ENV MAX_CHILDREN=100
ENV START_SERVER=30
ENV MIN_SPARE_SERVERS=30
ENV MAX_SPARE_SERVERS=50
ENV MAX_REQUESTS=500
ENV MAX_UPLOAD_SIZE=100M

#
# Service actions plus entrypoint for NGINX and PHP-FPM using supervisord
#
ADD ./scripts /usr/sbin

RUN cd /usr/sbin && chmod 700 \
    healthcheck \
    entrypoint \
    restart \
    stop \
    start

#
# Service actions for NGINX and PHP-FPM using supervisord
#

#
# Healtcheck (available for Docker >= 1.12)
#
HEALTHCHECK --interval=5s CMD healthcheck