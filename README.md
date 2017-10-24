docker-php7-nginx
---

Base image optimised for PHP 7.1 and NGINX, wrapped as Supervisor programs in order to provide a 12 factor app
environment. It doesn't bind SSL port (`443`): load-balancer is responsible for that. Port 8080 in order to don't run as
root (<= 1024 ports are privileged).


Commands
---
### `/usr/bin/start` aka start
Start supervisor default programs (`php-fpm` and `nginx`) configured in `/etc/supervisor/supervisord.conf`. Feel free to
add your custom programs in folder `/etc/supervisor/conf.d`.

Programs output like error and access log is set redirected to `STDOUT`, useful in order to use Docker logging capabilities.

### `/usr/bin/restart` aka restart
Restart **ALL** programs: useful if you would like to edit `php-fpm` or `nginx` configurations at runtime.

### `/usr/bin/stop` aka stop
Graceful shutdown of programs: this command stop all workers sending `SIGSTOP` signal, using Supervisord built-in command.
Feel free to stop on your own (e.g.: `docker exec <CONTAINER_ID> stop`) or using Docker one (e.g.: `docker stop <CONTAINER_ID>`).
The `entrypoint` will trap both `SIGTERM` and `SIGQUIT` in order to achieve graceful shutdown, useful if you cannot handle
pre-stop scripts provided by some schedulers.
Remember that the default amount of seconds before Supervisord will sending `SIGCHLD` is 10.



Environment variables
---

#### Workdir `WORKDIR`
Set to `/var/www`: NGINX serves folder `/var/www/public`. If you need to edit just replace default configuration on
`/etc/nginx/conf.d/default.conf`

#### dotEnv file `ENV_FILE`
dotEnv file is not mandatory: in case you want execute hard-provisioning (i.e.: `.env.production`) the file be copied to
main `.env` (ensure that the file exists or it will be ignored).
dotEnv can inject *all* environment variables due to `clear_env` configuration flag in `php-fpm` pool: it is not recommended
due to security issues


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



Health-checks
---
Checking every 5 seconds if PHP-FPM and NGINX are running: feel free to provide a `/ping` endpoint in your application.
