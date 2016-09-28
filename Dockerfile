FROM ubuntu:15.04

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install software-properties-common

# RUN apt-get update && apt-get -y install \
# 	curl \
# 	sudo

RUN apt-add-repository ppa:phalcon/stable
# RUN curl -s https://packagecloud.io/install/repositories/phalcon/stable/script.deb.sh | sudo bash

RUN apt-get update && apt-get -y install \
	curl \
	git \
	nginx-extras \
	php5-cli \
	php5-dev \
	php5-fpm \
	php5-gd \
	php5-xdebug \
	libpcre3-dev \
	gcc \
	make \
	php5-mysql \
	php5-curl \
	php5-phalcon

RUN echo 'extension=phalcon.so' >> /etc/php5/fpm/conf.d/30-phalcon.ini

ADD nginx.conf /etc/nginx/nginx.conf
ADD default /etc/nginx/sites-available/default

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

# RUN mkdir /var/www
RUN echo "<?php phpinfo(); ?>" > /var/www/index.php

VOLUME ["/var/www"]

EXPOSE 80

CMD service php5-fpm start && nginx
