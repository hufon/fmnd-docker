FROM php:7.1-apache

# Install needed software and dependencies
RUN DEBIAN_FRONTEND=noninteractive  \
apt-get update                      \
&& apt-get install -qy              \
git                                 \
libicu-dev                          \
libmcrypt-dev                       \
libpng-dev                          \
libjpeg-dev                         \
libxml2-dev                         \
libxml2-utils                       \
nano                                \
vim                                 \
nodejs                              \
mysql-client                        \
dnsutils                            \
libxslt-dev                         \
&& apt-get clean


# Install PHP extensions
RUN docker-php-ext-configure gd --with-jpeg-dir=/usr/include/

RUN docker-php-ext-install          \
gd                                  \
intl                                \
mbstring                            \
mcrypt                              \
opcache                             \
pdo_mysql                           \
soap                                \
xsl                                 \
zip

#Install apcu
RUN pecl install apcu-beta                                                              \
  && echo extension=apcu.so > /usr/local/etc/php/conf.d/apcu.ini

#Install redis
RUN pecl install redis                                                              \
  && echo extension=redis.so > /usr/local/etc/php/conf.d/redis.ini

RUN touch /usr/local/etc/php/conf.d/memory.ini                                          \
&& echo "memory_limit = 512M" > /usr/local/etc/php/conf.d/memory.ini                    \
&& echo "variables_order = \"EGPCS\"" > /usr/local/etc/php/conf.d/variable_order.ini

RUN touch /usr/local/etc/php/conf.d/upload.ini                                          \
&& echo "upload_max_filesize = 100M" > /usr/local/etc/php/conf.d/upload.ini

RUN touch /usr/local/etc/php/conf.d/opcache.ini                                          \
&& echo "opcache.max_accelerated_files=20000" > /usr/local/etc/php/conf.d/opcache.ini    \
&& echo "opcache.memory_consumption=256" >> /usr/local/etc/php/conf.d/opcache.ini    \
&& echo "opcache.memory_consumption=256" >> /usr/local/etc/php/conf.d/opcache.ini 

RUN a2enmod headers                 \
&& a2enmod rewrite

 # Install and setup composer
RUN curl -sS https://getcomposer.org/installer | php           \
&&  mv composer.phar /usr/local/bin/composer
RUN usermod -aG root www-data

RUN sed -i 's!/var/www/html!/var/www/html/web!g' /etc/apache2/sites-available/000-default.conf \
&& mkdir /var/www/html/var && chmod 777 /var/www/html/var
