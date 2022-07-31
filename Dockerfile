FROM php:8.1-fpm

# RUN apt-get update && apt-get install -y libmemcached-dev zlib1g-dev \
#    libfreetype6-dev libjpeg62-turbo-dev libpng-dev \
#    && pecl install memcached-3.2.0 \
#    && pecl install redis-5.3.7 \
#    && pecl install xdebug-2.8.1 \
#    && docker-php-ext-configure gd --with-freetype --with-jpeg \
#    && docker-php-ext-enable memcached redis xdebug

RUN pecl install redis-5.3.7 \
    && docker-php-ext-enable redis \
    && docker-php-ext-install -j$(nproc) bcmath && docker-php-source delete

# Use the default production configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
