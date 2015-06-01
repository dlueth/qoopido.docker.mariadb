FROM phusion/baseimage:latest
MAINTAINER Dirk Lüth <info@qoopido.com>

# Initialize environment
	CMD ["/sbin/my_init"]
	ENV DEBIAN_FRONTEND noninteractive

# based on dgraziotin/docker-osx-lamp
	ENV DOCKER_USER_ID 501 
	ENV DOCKER_USER_GID 20
	ENV BOOT2DOCKER_ID 1000
	ENV BOOT2DOCKER_GID 50

# Tweaks to give MySQL write permissions to the app
	RUN useradd -r mysql -u ${BOOT2DOCKER_ID} && \
    	usermod -G staff mysql && \
    	groupmod -g $(($BOOT2DOCKER_GID + 10000)) $(getent group $BOOT2DOCKER_GID | cut -d: -f1) && \
    	groupmod -g ${BOOT2DOCKER_GID} staff

# alter package sources
	RUN rm -rf /etc/apt/sources.list
	ADD other/sources.list /etc/apt/sources.list

# install packages
	RUN apt-get update && \
		apt-get install -qy mariadb-server

# alter configuration files & directories
	RUN rm -rf /var/lib/mysql && \
		rm -rf /etc/mysql/my.cnf && \
		rm -rf /app/config/mariadb && \
		rm -rf /app/mariadb
	ADD app/config/mariadb /app/config/mariadb
	RUN mkdir -p /app/mariadb && \
		mkdir -p /app/logs
	
# add run-scripts
	ADD other/00_initialize.sh /etc/my_init.d/00_initialize.sh
	ADD other/01_start_mariadb.sh /etc/my_init.d/01_start_mariadb.sh
	RUN chmod +x /etc/my_init.d/*.sh && \
		chmod 755 /etc/my_init.d/*.sh

# cleanup
	RUN apt-get clean && \
		rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# finalize
	VOLUME ["/app/mysql", "/app/config/mysql", "/app/logs"]
	EXPOSE 3306
