docker-php7-nginx
---

Base image optimised for PHP 7.1 and NGINX, wrapped as Supervisor programs in order to provide a 12 factors app
environment. It doesn't bind SSL port (`443`): load-balancer is responsible for that.



Commands
---
### `/usr/sbin/start` aka start
Execute a chown of `WORKDIR` content according to nginx/php-fpm user (default: `www-data`) and start supervisor programs
configured in `/etc/supervisor/conf.d/start.conf`.

Programs output like error and access log is set redirected to `STDOUT` in order to enable AWS Cloud Watch tailing.

### `/usr/sbin/restart` aka restart
Restart **ALL** programs: useful if you would like to edit nginx/php-fpm configurations.

### `/usr/sbin/stop` aka stop
Graceful shutdown of programs.



Environment variables
---

#### Workdir `WORKDIR`
Set to `/var/www`: NGINX serves folder `/var/www/public`. If you need to edit just replace default configuration on
`/etc/nginx/conf.d/default.conf`

#### dotEnv file `ENV_FILE`
dotEnv file is not mandatory: in case you want execute hard-provisioning (i.e.: `.env.production`) the file be copied to
main `.env` (ensure that the file exists or it will be ignored).
Remember that dotEnv inject all environment variables so you can use docker ones as well.


#### PHP-FPM
- `LISTEN` The PHP-FPM listener, default value set to `127.0.0.1:9000` (using TCP/IP due to higher scalability).
- `MAX_CHILDREN` The number of child processes to be created
                 (reference: https://myshell.co.uk/blog/2012/07/adjusting-child-processes-for-php-fpm-nginx/)
- `START_SERVER` The number of child processes created on startup: should be higher than `MIN_SPARE_SERVERS`
- `MIN_SPARE_SERVERS` The desired minimum number of idle server processes
- `MAX_SPARE_SERVERS` The desired maximum number of idle server processes in order to avoid 104 errors
                      (Connection reset by peer)
- `MAX_REQUESTS` The number of requests each child process should execute before respawning. This can be useful to work
                 around memory leaks in 3rd party libraries. For endless request processing specify 0

#### PHP-FPM + NGINX
- `MAX_UPLOAD_SIZE` Max upload size



Healtchecks
---
Checking every 5 seconds if PHP-FPM and NGINX are running: feel free to provide a `/ping` endpoint in your application.