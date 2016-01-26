FROM ubuntu:15.04

RUN apt-get update && apt-get -y install \
	git \
	nginx-extras \
	php5-cli \
	php5-dev \
	php5-fpm \
	libpcre3-dev \
	gcc \
	make \
	php5-mysql \
	curl \
	php5-curl

RUN git clone --depth=1 http://github.com/phalcon/cphalcon.git -b master cphalcon
RUN cd cphalcon && git checkout tags/phalcon-v2.0.9
# RUN cd cphalcon/build && ./install;
# From https://github.com/phalcon/cphalcon/issues/1385#issuecomment-26410069
RUN cd cphalcon/build/64bits && phpize && ./configure CFLAGS="-O2 -g -fomit-frame-pointer -DPHALCON_RELEASE" && make && make install

RUN echo 'extension=phalcon.so' >> /etc/php5/fpm/conf.d/30-phalcon.ini

ADD nginx.conf /etc/nginx/nginx.conf
ADD default /etc/nginx/sites-available/default

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

RUN mkdir /var/www
RUN echo "<?php phpinfo(); ?>" > /var/www/index.php

VOLUME ["/var/www"]

EXPOSE 80

CMD service php5-fpm start && nginx
