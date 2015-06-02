# Build container #
```
docker build -t mit/mariadb .
```

# Run container #
```
docker run -d -P -t -i -p 3306:3306 \
	-v [local path to mariadb database]:/app/mariadb \
	-v [local path to mariadb logs]:/app/logs \
	-v [local path to mariadb config *]:/app/config \
	--name mariadb mit/mariadb
```

# Open shell in container #
```
docker exec -i -t "mariadb" /bin/bash
```

# Project specific configuration #
Any files under /app/config will be symlinked into the container filesystem beginning at the root directory. This can be used to, e.g., overwrite default my.cnf configuration with a custom and project specific configuration. Be careful changing any of the default paths used for exposing shared directories (logs) though as these might break things.