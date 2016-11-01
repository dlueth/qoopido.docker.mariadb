tag?=develop

build:
	docker build --no-cache=true -t qoopido/mariadb:${tag} .