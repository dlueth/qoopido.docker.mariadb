#!/bin/bash

files=($(find /app/config/mariadb -type f))

for source in "${files[@]}" 
do
	pattern="\.DS_Store"
	target=${source/\/app\/config\/mariadb/\/etc\/mysql}
	
	if [[ ! $target =~ $pattern ]]; then
		if [[ -f $target ]]; then
			echo "    Removing \"$target\"" && rm -rf $target
		fi
		
		echo "    Linking \"$source\" to \"$target\"" && mkdir -p $(dirname "${target}") && ln -s $source $target
	fi
done

mkdir -p /app/mariadb
mkdir -p /app/logs/mariadb

if [[ ! -f /app/mariadb/dump.sql ]]; then
	echo "    Initializing new database"
	
	/usr/bin/mysql_install_db > /dev/null 2>&1
	/usr/bin/mysqld_safe --skip-syslog --skip-networking > /dev/null 2>&1 &

	RET=1
	while [[ RET -ne 0 ]]; do
		sleep 1
		/usr/bin/mysql -uroot -e "status" > /dev/null 2>&1
		RET=$?
	done
	
	/usr/bin/mysql -uroot -e "CREATE USER 'admin'@'%' IDENTIFIED BY 'fyoDBafo'"
	/usr/bin/mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION"
	/usr/bin/mysqldump -uroot --hex-blob --routines --triggers --skip-lock-tables --all-databases > /app/mariadb/dump.sql
	/usr/bin/mysqladmin -uroot shutdown
	
	echo "    successfully initialized new database"
else
	echo "    Importing existing database"
	
	/usr/bin/mysqld_safe --skip-syslog --skip-networking > /dev/null 2>&1 &
	
	RET=1
	while [[ RET -ne 0 ]]; do
		sleep 1
		/usr/bin/mysql -uroot -e "status" > /dev/null 2>&1
		RET=$?
	done
	
	/usr/bin/mysql -uroot < /app/mariadb/dump.sql
	/usr/bin/mysqladmin -uroot shutdown
	
	echo "    successfully imported existing database"
fi

# Tweaks to give MySQL write permissions to the app
# chown -R mysql:staff /var/lib/mysql
# chown -R mysql:staff /var/run/mysqld
# chmod -R 770 /var/lib/mysql
# chmod -R 770 /var/run/mysqld