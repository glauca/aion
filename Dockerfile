FROM php:8.1-fpm-alpine

ENV TIMEZONE Asia/Shanghai

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk update \
    && apk add --no-cache freetype freetype-dev libpng libpng-dev libjpeg-turbo libjpeg-turbo-dev libmcrypt-dev libxml2-dev \
    && apk add --no-cache --virtual .build-deps g++ make autoconf \
    && pecl install redis-5.3.7 \
    && docker-php-ext-enable redis \
    && pecl install mcrypt-1.0.5 \
    && docker-php-ext-enable mcrypt \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) bcmath gd mysqli pdo pdo_mysql opcache sockets soap zip \
    && cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && echo "${TIMEZONE}" > /etc/timezone \
    && rm -fr /tmp/pear \
    && apk del .build-deps freetype-dev libpng-dev libjpeg-turbo-dev


# RUN apt-get update && apt-get install -y libmemcached-dev zlib1g-dev \
#    libfreetype6-dev libjpeg62-turbo-dev libpng-dev \
#    && pecl install memcached-3.2.0 \
#    && pecl install redis-5.3.7 \
#    && pecl install xdebug-2.8.1 \
#    && docker-php-ext-configure gd --with-freetype --with-jpeg \
#    && docker-php-ext-enable memcached redis xdebug

# RUN apt-get update && apt-get install -y libzip-dev

# RUN pecl install redis-5.3.7 \
#     && docker-php-ext-enable redis \
#     && docker-php-ext-enable zip \
#     && docker-php-ext-install -j$(nproc) bcmath mysqli pdo pdo_mysql zip \
#     && docker-php-source delete

# Use the default production configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
