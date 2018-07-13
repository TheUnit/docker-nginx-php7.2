# Docker: Ubuntu, Nginx and PHP Stack

This image is based on the [phusion/baseimage-docker](https://github.com/phusion/baseimage-docker) base Ubuntu image and is heavily inspired by [fideloper/docker-nginx-php](https://github.com/fideloper/docker-nginx-php).

Available on [Docker Hub](https://hub.docker.com/r/theunit/nginx-php7.2).

## Overview
- PHP 7.2.7
- Nginx
- Composer

## Running the Container

```bash
docker run -d --restart always \
    -v /path/to/app:/var/www/html:rw \
    -p 80:80 \
    theunit/nginx-php7.2:1.0.0 /sbin/my_init
```

#### Docker Compose

```yaml
version: "2"
services:
    myapp:
        image: theunit/nginx-php7.2:1.0.0
        volumes:
            - /path/to/app:/var/www/html
        ports:
            - 80:80
```

Once the container is running you should be able to navigate to `http://localhost` in your browser to access your web app.

If using `docker-machine` then replace `localhost` in the url with the IP of the Docker machine the container is running on.

## Custom Nginx Config

If you want to use your own custom vhost config you can do so by mounting it to `/etc/nginx/sites-available/default`:

```bash
docker run -d --restart always \
    -v /path/to/app:/var/www/html:rw \
    -v /path/to/nginx.conf:/etc/nginx/sites-available/default \ 
    -p 80:80 \
    theunit/nginx-php7.2:1.0.0 /sbin/my_init
```

#### Docker Compose

```yaml
version: "2"
services:
    myapp:
        image: theunit/nginx-php7.2:1.0.0
        volumes:
            - /path/to/app:/var/www/html
            - /path/to/nginx.conf:/etc/nginx/sites-available/default
        ports:
            - 80:80
```