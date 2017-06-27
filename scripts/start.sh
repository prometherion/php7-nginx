#!/bin/bash


# Always chown webroot for better mounting
chown -Rf --verbose www-data:www-data ${PWD}

# Supervisord
echo "Starting supervisord for NGINX and PHP-FPM..."
supervisord -n -c /etc/supervisor/supervisord.conf