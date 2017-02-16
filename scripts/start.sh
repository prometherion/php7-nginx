#!/bin/bash

# Always chown webroot for better mounting
chown -Rf www-data:www-data /var/www

# PHP-FPM tuning
sed -i -e 's#listen\s*=\s*127.0.0.1:9000#listen = '$LISTEN'#g' \
	-e "s/pm.max_children\s*=\s*5/pm.max_children = $MAX_CHILDREN/g" \
	-e "s/pm.start_servers\s*=\s*2/pm.start_servers = $START_SERVER/g" \
	-e "s/pm.min_spare_servers\s*=\s*1/pm.min_spare_servers = $MIN_SPARE_SERVERS/g" \
	-e "s/pm.max_spare_servers\s*=\s*3/pm.max_spare_servers = $MAX_SPARE_SERVERS/g" \
	-e "s/;pm.max_requests\s*=\s*500/pm.max_requests = $MAX_REQUESTS/g" \
	-e "s/;listen.owner\s*=\s*www-data/listen.owner = www-data/g" \
	-e "s/;listen.group\s*=\s*www-data/listen.group = www-data/g" \
	-e "s/;listen.mode\s*=\s*www-data/listen.mode = 0660/g" \
	/usr/local/etc/php-fpm.d/www.conf

# Supervisord
supervisord -n