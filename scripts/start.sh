#!/bin/bash

echo "Performances tuned PHP-FPM variables:"
echo " - listening on {$LISTEN} as www-data:www-data with mode 0660"
echo " - max children: {$MAX_CHILDREN}"
echo " - start servers: {$START_SERVER}"
echo " - min spare servers: {$MIN_SPARE_SERVERS}"
echo " - max spare servers: {$MAX_SPARE_SERVERS}"
echo " - max requests: {$MAX_REQUESTS}"
echo " - max upload size: {$MAX_UPLOAD_SIZE}"

if [[ ${ENABLE_LOG:0} == 1 && $PAPERTRAIL_DOMAIN && $PAPERTRAIL_PORT && $LOG_HOSTNAME && $LOG_FILES ]]; then
	echo "PaperTrail as logging driver is enabled:"
	echo " - domain: {$PAPERTRAIL_DOMAIN}:{$PAPERTRAIL_PORT}"
	echo " - logging as: {$LOG_HOSTNAME}"
	echo " - log files: {$LOG_FILES}"
elif [[ ${ENABLE_LOG} == 0 ]]; then
	echo "PaperTrail as logging driver has NOT been enabled: hope you're in dev environment..."
fi

# Always chown webroot for better mounting
chown -Rf --verbose www-data:www-data ${PWD}

# Supervisord
echo "Starting supervisord for NGINX and PHP-FPM..."
supervisord -n -c /etc/supervisor/supervisord.conf