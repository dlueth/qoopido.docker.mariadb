#!/bin/bash

mkdir -p /app/data/logs
mkdir -p /app/data/database
mkdir -p /app/config

FILES=($(find /app/config -type f \( -not -name ".DS_Store" \)))

for source in "${FILES[@]}"
do
	target=${source/\/app\/config/\/etc\/mysql}

	if [[ -f $target ]]; then
		echo "    Removing \"$target\"" && rm -rf $target
	fi

	echo "    Linking \"$source\" to \"$target\"" && mkdir -p $(dirname "${target}") && ln -s $source $target
done

if [[ ! -f /app/data/database/dump.sql ]]; then
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
	/usr/bin/mysqldump -uroot --hex-blob --routines --triggers --skip-lock-tables --all-databases > /app/data/database/dump.sql
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
	
	/usr/bin/mysql -uroot < /app/data/database/dump.sql
	/usr/bin/mysqladmin -uroot shutdown
	
	echo "    successfully imported existing database"
fi