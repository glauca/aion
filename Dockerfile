FROM php:8.1-fpm-alpine

ENV TIMEZONE Asia/Shanghai

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk update \
    && apk add shadow && usermod -u 1000 www-data \
    && apk add --no-cache freetype freetype-dev libpng libpng-dev libjpeg-turbo libjpeg-turbo-dev \
    && apk add --no-cache libmcrypt-dev libxml2-dev libzip-dev icu icu-dev tzdata \
    && apk add --no-cache --virtual .build-deps g++ make autoconf \
    && apk add --no-cache git
    && pecl install redis-5.3.7 \
    && docker-php-ext-enable redis \
    && pecl install mcrypt-1.0.5 \
    && docker-php-ext-enable mcrypt \
    && pecl install trader-0.5.1 \
    && docker-php-ext-enable trader \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) bcmath exif gd intl mysqli pdo_mysql opcache sockets soap zip \
    && cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && echo "${TIMEZONE}" > /etc/timezone \
    && rm -fr /tmp/pear \
    && apk del .build-deps freetype-dev libpng-dev libjpeg-turbo-dev icu-dev tzdata \
    && php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer

# PHP Ldap
# RUN apk add ldb-dev libldap openldap-dev && docker-php-ext-install -j$(nproc) ldap

# For Linux
# RUN usermod -u 1000 www-data

# For Mac
# RUN usermod -u 1000 www-data && usermod -G staff www-data

# Use the default production configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
#COPY "./php/php.ini" "$PHP_INI_DIR/php.ini"
