FROM ubuntu:12.04

# install the PHP extensions
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
	libpng12-dev libjpeg-dev cron supervisor vim libmagickwand-dev libmagickcore-dev imagemagick unzip \
	apache2 php5-dev libapache2-mod-php5 php5-gd php5-mysql php-pear \
	&& apt-get autoremove \
	&& apt-get autoclean \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# set xdebug
# see https://gist.github.com/chadrien/c90927ec2d160ffea9c4
#RUN yes | pecl install xdebug-2.2.7 \
#	&& echo "zend_extension=$(find /usr/lib/php/extensions/ -name xdebug.so)" > /etc/php/conf.d/xdebug.ini \
#	&& echo "xdebug.remote_enable=on" >> /etc/php/conf.d/xdebug.ini \
#	&& echo "xdebug.remote_autostart=off" >> /etc/php/conf.d/xdebug.ini
#
## ImageMaigck
#RUN yes | pecl install imagick \
#	&& echo "extension=$(find /usr/lib/php/extensions/ -name imagick.so)" > /etc/php/conf.d/imagick.ini
#
## set extra PHP.ini settings
#RUN { \
#		echo 'date.timezone="Asia/Tokyo"'; \
#		echo 'log_errors=On'; \
#		echo 'memory_limit=-1'; \
#		echo 'max_execution_time=0'; \
#		echo 'post_max_size=0'; \
#		echo 'upload_max_filesize=2048G'; \
#	} > /etc/php/conf.d/php-extra.ini
#

# fix permission for osx
RUN usermod -u 1000 www-data \
	&& usermod -G staff www-data

RUN a2enmod rewrite expires

VOLUME /var/www/html

ENV TZ JST-9
ENV XDEBUG_CONFIG remote_host=
ENV CONCRETE5_VERSION 5.5.2.1

COPY docker-entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["source /etc/apache2/envvars | /usr/sbin/apache2 -DFOREGROUND"]