# recommended directory structure #
Like with my other containers I encourage you to follow a unified directory structure approach to keep things simple & maintainable, e.g.:

```
project root
  - docker_compose.yaml
  - config
    - mariadb
      - conf.d
        - ...
  - mariadb
    - dump.sql
  - logs
```

# Example docker_compose.yaml #
```
db:
  image: qoopido/mariadb:latest
  ports:
   - "3306:3306"
  volumes:
   - ./config:/app/config
   - ./mariadb:/app/mariadb
   - ./logs:/app/logs
```

# Or start container manually #
```
docker run -d -P -t -i -p 3306:3306 \
	-v [local path to config]:/app/config \
	-v [local path to mariadb]:/app/mariadb \
	-v [local path to logs]:/app/logs \
	--name db qoopido/mariadb:latest
```

# Credentials #
```root``` is restricted to access from localhost and does not have any password. ```admin``` is provided for general access using ```fyoDBafo``` as password.

# Database import/export #
This container will create a file named ```dump.sql``` in ```/app/mariadb``` on first execution and will export a fresh dump whenever the container gets stopped. If the file exists it will get imported when the container is started again.

Both im- and export will take some time but have major advantages regarding git or svn versioning. For bigger databases please make sure to add e.g. ```-t 600``` (default is 10, afterwards docker force-kills the container) option to ```docker-compose up``` as well as ```docker stop``` and ```docker-compose stop``` to ensure the dump can be imported/exported successfully before container shutdown.

# Configuration #
Any files under ```/app/config/mariadb``` will be symlinked into the container's filesystem beginning at ```/etc/mysql```. This can be used to overwrite the container's default maria configuration with a custom, project specific configuration.