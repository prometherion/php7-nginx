FROM php:7.1.1-fpm

MAINTAINER prometherion <dario.tranchitella@starteed.com>

EXPOSE 8080

WORKDIR /var/www

#
# Service actions plus entrypoint for NGINX and PHP-FPM using supervisord
#
ADD ./scripts /usr/sbin

#
# Installing Composer
#
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
	php composer-setup.php --install-dir=/usr/bin --filename=composer && \
	php -r "unlink('composer-setup.php');" \
    && apt-get update && apt-get install -y \
	nginx \
	supervisor \
	git \
	zip \
	unzip \
	zlib1g-dev \
    && rm -rf /etc/nginx/sites-* \
    && docker-php-ext-install zip \
    && chown -R www-data /var/log/supervisor && chmod 775 -R /var/log/supervisor \
    && chown -R www-data /etc/nginx && chmod 775 -R /etc/nginx \
    && chown -R www-data /var/lib/nginx && chmod 775 -R /var/lib/nginx \
    && chown -R www-data ${PHP_INI_DIR}/../php-fpm.d && chmod 775 -R ${PHP_INI_DIR}/../php-fpm.d \
    && touch ${PHP_INI_DIR}/php.ini && chown -R www-data ${PHP_INI_DIR}/php.ini && chmod 775 -R ${PHP_INI_DIR}/php.ini \
    && mkdir /run/prometherion && chown -R www-data /run/prometherion && chmod 775 -R /run/prometherion \
    && touch /usr/local/var/log/php-fpm.log && chmod 775 /usr/local/var/log/php-fpm.log && chown www-data /usr/local/var/log/php-fpm.log \
    && cd /usr/sbin && chmod 775 \
        healthcheck \
	entrypoint \
	restart \
	stop \
	start

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

ENTRYPOINT ["entrypoint"]

CMD ["start"]

#
# Adding custom NGINX custom configuration for PHP-FPM (optimized for PHP-FPM and already non-daemoned)
#
ADD conf/default.conf /etc/nginx/conf.d/default.conf
ADD conf/nginx.conf /etc/nginx/nginx.conf

#
# Setting Supervisord configuration
#
ADD ./conf/supervisord.conf /etc/supervisor/supervisord.conf

#
# Healtcheck (available for Docker >= 1.12)
#
HEALTHCHECK --interval=5s CMD healthcheck

#
# Using non-root user in order to enhance security
#
USER www-data
