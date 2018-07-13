FROM phusion/baseimage:0.10.1

MAINTAINER The Unit <developers@theunit.co.uk>

# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

ENV HOME /root

RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

CMD ["/sbin/my_init"]

RUN apt-get update

RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y \
    curl \
    python-software-properties \
    software-properties-common \
    unzip \
    vim \
    wget \
    zip

# Install PHP 7.2 and some useful extensions.
RUN add-apt-repository -y ppa:ondrej/php && \
    add-apt-repository -y ppa:nginx/stable && \
    apt-get update
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y --force-yes \
    php7.2-curl \
    php7.2-fpm \
    php7.2-mbstring \
    php7.2-mysqlnd \
    php7.2-xml

# Setup PHP.
RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php/7.2/fpm/php.ini && \
    sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php/7.2/cli/php.ini && \
    sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.2/fpm/php.ini && \
    sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.2/cli/php.ini && \
    sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.2/fpm/php-fpm.conf

# Install Nginx.
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y nginx

# Setup Nginx.
COPY conf/nginx.conf /etc/nginx/sites-available/default
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN rm /var/www/html/index.nginx-debian.html && \
    echo "<?php phpinfo();" > /var/www/html/index.php

# Install composer.
RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer && \
    curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig && \
    # Make sure we're installing what we think we're installing!
    php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }" && \
    php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer --snapshot && \
    rm -f /tmp/composer-setup.*

# Start PHP & Nginx on boot.
RUN mkdir /etc/service/nginx && \
    mkdir /etc/service/php-fpm
ADD runit/nginx.sh /etc/service/nginx/run
ADD runit/php-fpm.sh /etc/service/php-fpm/run
RUN chmod +x /etc/service/nginx/run && \
    chmod +x /etc/service/php-fpm/run

# Add init scripts.
COPY init.d/ /etc/my_init.d
RUN find /etc/my_init.d -type f -exec chmod +x {} \;

# Clean up.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Expose HTTP port.
EXPOSE 80