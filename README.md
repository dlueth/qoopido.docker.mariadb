# Build container #
```
docker build -t qoopido/mariadb .
```

# Run container manually ... #
```
docker run -d -P -t -i -p 3306:3306 \
	-v [local path to mariadb db storage location]:/app/mariadb \
	-v [local path to logs]:/app/logs \
	-v [local path to config]:/app/config \
	--name mariadb qoopido/mariadb
```

# ... or use docker-compose #
```
mariadb:
  image: qoopido/mariadb
  ports:
   - "3306:3306"
  volumes:
   - ./mariadb:/app/mariadb
   - ./logs:/app/logs
   - ./config:/app/config
```

# Open shell #
```
docker exec -i -t "mariadb" /bin/bash
```

# Credentials #
```root``` is restricted to access from localhost and does not have any password. ```admin``` is provided for general access using ```fyoDBafo``` as password.

# Project specific configuration #
Any files under ```/app/config/mariadb``` will be symlinked into the container's filesystem beginning at ```/etc/mysql```. This can be used to overwrite the container's default maria configuration with a custom, project specific configuration.

This container will create a file named ```dump.sql``` in ```./mariadb``` on first execution and will export a fresh dump whenever the container gets stopped. If the file exists it will get imported when the container is started. Both import and export will take some time but have major advantages regarding git or svn versioning. For bigger databases please make sure to add ```-t 600``` option (adjust numeric value in seconds accordingly) to ensure the dump can be exported successfully.
