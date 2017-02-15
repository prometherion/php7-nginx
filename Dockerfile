FROM php:7.1.1-fpm

MAINTAINER prometherion <dario.tranchitella@starteed.com

# Updating repositories
RUN apt-get update

# Installing NGINX with 
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
RUN apt-get install -y git zip unzip  zlib1g-dev
RUN docker-php-ext-install zip

# PHP-FPM environment variables for performance tuning
ENV LISTEN=/var/run/php-fpm.sock
ENV MAX_CHILDREN=100
ENV START_SERVER=20
ENV MIN_SPARE_SERVERS=10
ENV MAX_SPARE_SERVERS=20
ENV MAX_REQUESTS=500

RUN sed -i -e 's#listen\s*=\s*127.0.0.1:9000#listen = '$LISTEN'#g' \
	-e "s/pm.max_children\s*=\s*5/pm.max_children = $MAX_CHILDREN/g" \
	-e "s/pm.start_servers\s*=\s*2/pm.start_servers = $START_SERVER/g" \
	-e "s/pm.min_spare_servers\s*=\s*1/pm.min_spare_servers = $MIN_SPARE_SERVERS/g" \
	-e "s/pm.max_spare_servers\s*=\s*3/pm.max_spare_servers = $MAX_SPARE_SERVERS/g" \
	-e "s/;pm.max_requests\s*=\s*500/pm.max_requests = $MAX_REQUESTS/g" \
	-e "s/;listen.owner\s*=\s*www-data/listen.owner = www-data/g" \
	-e "s/;listen.group\s*=\s*www-data/listen.group = www-data/g" \
	-e "s/;listen.mode\s*=\s*www-data/listen.mode = 0660/g" \
	/usr/local/etc/php-fpm.d/www.conf

# Cleaning up
RUN apt-get remove --purge -y $BUILD_PACKAGES $(apt-mark showauto) && rm -rf /var/lib/apt/lists/*

EXPOSE 80 9000

WORKDIR /var/www

CMD ["/usr/bin/supervisord", "-n"]