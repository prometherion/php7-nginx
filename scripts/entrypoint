#!/bin/bash
set -e

#
# NGINX tuning
#
sed -i -e "s/client_max_body_size\s100M;/client_max_body_size $MAX_UPLOAD_SIZE;/gi" /etc/nginx/nginx.conf

#
# PHP-FPM tuning
#
sed -i -e 's#listen\s*=\s*127.0.0.1:9000#listen = '$LISTEN'#g' \
	-e "s/pm.max_children\s*=\s*5/pm.max_children = $MAX_CHILDREN/g" \
	-e "s/pm.start_servers\s*=\s*2/pm.start_servers = $START_SERVER/g" \
	-e "s/pm.min_spare_servers\s*=\s*1/pm.min_spare_servers = $MIN_SPARE_SERVERS/g" \
	-e "s/pm.max_spare_servers\s*=\s*3/pm.max_spare_servers = $MAX_SPARE_SERVERS/g" \
	-e "s/;pm.max_requests\s*=\s*500/pm.max_requests = $MAX_REQUESTS/g" \
	-e "s/;listen.owner\s*=\s*www-data/listen.owner = www-data/g" \
	-e "s/;listen.group\s*=\s*www-data/listen.group = www-data/g" \
	-e "s/;listen.mode\s*=\s*0660/listen.mode = 0660/g" \
	${PHP_INI_DIR}/../php-fpm.d/www.conf

#
# Overriding max upload size for php.ini
#
echo "upload_max_filesize = $MAX_UPLOAD_SIZE
post_max_size = $MAX_UPLOAD_SIZE" > ${PHP_INI_DIR}/php.ini

#
# dotEnv environment file
#
if [[ ${ENV_FILE} && -f ${PWD}/${ENV_FILE} ]]; then
    cat ${PWD}/${ENV_FILE} > ${PWD}/.env
    echo "Setting ${ENV_FILE} as main dotEnv file in ${PWD}"
elif [ ! -f ${PWD}/.env ]; then
    echo "WARNING: no dotEnv file has been chosen!"
else
    echo "Using built dotEnv file located in ${PWD}/.env "
fi

exec "$@"