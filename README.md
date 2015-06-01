# Build container #
docker build -t mit/mariadb .

# Run container #
docker run -d -P -t -i -p 3306:3306 && \
	-v [local path to mariadb database]:/app/mariadb && \
	-v [local path to mariadb logs]:/app/logs && \
	-v [local path to mariadb config *]:/app/config/mariadb && \
	--name mariadb mit/mariadb

# Open shell in container #
docker exec -i -t "mariadb" /bin/bash

# Allowed configuration files #
- mariadb
	- my.cnf => /etc/mysql/my.cnf