FROM php:7.1.1-fpm

MAINTAINER prometherion <dario.tranchitella@starteed.com

# Updating repositories
RUN apt-get update

# Installing NGINX with default configuration file
RUN apt-get install nginx -y
COPY conf/nginx.conf /etc/nginx/sites-enabled/default

# Installing Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
	php composer-setup.php --install-dir=/usr/bin --filename=composer && \
	php -r "unlink('composer-setup.php');"

# Installing Supervisor
RUN apt-get install supervisor -y
COPY conf/supervisor.conf /etc/supervisor/conf.d/start.conf

# Installing Git and Zip/Unzip for Composer speed up
RUN apt-get install -y git zip unzip zlib1g-dev
RUN docker-php-ext-install zip

# PHP-FPM environment variables for performance tuning
ENV LISTEN=127.0.0.1:9000
ENV MAX_CHILDREN=100
ENV START_SERVER=30
ENV MIN_SPARE_SERVERS=30
ENV MAX_SPARE_SERVERS=50
ENV MAX_REQUESTS=500
ENV MAX_UPLOAD_SIZE=100M

# Cleaning up
RUN rm -rf /var/lib/apt/lists/*

EXPOSE 80 9000

WORKDIR /var/www

# Start script
COPY ./scripts/start.sh /start.sh
RUN chmod 755 /start.sh
CMD ["/start.sh"]