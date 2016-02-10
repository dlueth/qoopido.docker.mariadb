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
    	
# configure defaults
	ADD configure.sh /configure.sh
	ADD config /config
	RUN chmod +x /configure.sh && \
		chmod 755 /configure.sh
	RUN /configure.sh && \
		chmod +x /etc/my_init.d/*.sh && \
		chmod 755 /etc/my_init.d/*.sh && \
		chmod +x /etc/service/mariadb/run && \
		chmod 755 /etc/service/mariadb/run

# install packages
	RUN apt-get update && \
		apt-get -qy upgrade && \
		apt-get -qy dist-upgrade && \
		apt-get install -qy mariadb-server

# add default /app directory
	ADD app /app
	RUN mkdir -p /app/mariadb && \
		mkdir -p /app/logs/mariadb
	
# cleanup
	RUN apt-get clean && \
		rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /configure.sh

# finalize
	VOLUME ["/app/mariadb", "/app/logs", "/app/config"]
	EXPOSE 3306
