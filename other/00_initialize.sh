#!/bin/bash

ln -s /app/config/mariadb/my.cnf /etc/mysql/my.cnf

if [[ ! -d /app/mariadb/mysql ]]; then
	/usr/bin/mysql_install_db > /dev/null 2>&1
	
	mv /var/lib/mysql/* /app/mariadb/
	rm -rf /var/lib/mysql
	ln -s /app/mariadb /var/lib/mysql
		
	/usr/bin/mysqld_safe > /dev/null 2>&1 &

	RET=1
	while [[ RET -ne 0 ]]; do
		sleep 5
		mysql -uroot -e "status" > /dev/null 2>&1
		RET=$?
	done
	
	mysql -uroot -e "CREATE USER 'admin'@'%' IDENTIFIED BY 'fyoDBafo'"
	mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION"

	mysqladmin -uroot shutdown
	
	mv /var/log/mysql /app/logs/mariadb
	ln -s /app/logs/mariadb /var/log/mysql
else
	ln -s /app/mariadb /var/lib/mysql
	ln -s /app/logs/mariadb /var/log/mysql
fi