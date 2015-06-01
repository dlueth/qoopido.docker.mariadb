#!/bin/bash
exec mysqld_safe

# Tweaks to give MySQL write permissions to the app
chown -R mysql:staff /var/lib/mysql
chown -R mysql:staff /var/run/mysqld
chmod -R 770 /var/lib/mysql
chmod -R 770 /var/run/mysqld