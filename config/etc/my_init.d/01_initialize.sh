#!/bin/bash

files=($(find /app/config -type f))

for source in "${files[@]}"
do
	pattern="\.DS_Store"
	target=${source/\/app\/config/}
	
	if [[ ! $target =~ $pattern ]]; then
		if [[ -f $target ]]; then
			echo "[remove] \"$target\"" && rm -rf $target
		fi
		
		echo "[link] \"$source\" to \"$target\"" && mkdir -p $(dirname "${target}") && ln -s $source $target
	fi
done

mkdir -p /app/mariadb

if [[ ! -d /app/mariadb/mysql ]]; then
	rm -rf /var/lib/mysql
	
	mysql_install_db > /dev/null 2>&1
	mysqld_safe > /dev/null 2>&1 &

	RET=1
	while [[ RET -ne 0 ]]; do
		sleep 5
		mysql -uroot -e "status" > /dev/null 2>&1
		RET=$?
	done
	
	mysql -uroot -e "CREATE USER 'admin'@'%' IDENTIFIED BY 'fyoDBafo'"
	mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION"
	mysqladmin -uroot shutdown
	
	mv /var/lib/mysql/* /app/mariadb/
fi

rm -rf /var/log/mysql
ln -s /app/logs/mariadb /var/log/mysql

rm -rf /var/lib/mysql
ln -s /app/mariadb /var/lib/mysql

exec mysqld_safe

# Tweaks to give MySQL write permissions to the app
chown -R mysql:staff /var/lib/mysql
chown -R mysql:staff /var/run/mysqld
chmod -R 770 /var/lib/mysql
chmod -R 770 /var/run/mysqld