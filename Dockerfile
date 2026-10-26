FROM php:8.3.36-fpm-alpine

ENV TIMEZONE=Asia/Shanghai
ENV TZ=Asia/Shanghai

# 换中科大源 + 基础依赖
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
    && apk update \
    && apk add --no-cache linux-headers alpine-sdk autoconf openssl-dev \
    && apk add shadow && usermod -u 1000 www-data \
    && apk add --no-cache freetype freetype-dev libpng libpng-dev libjpeg-turbo libjpeg-turbo-dev \
    && apk add --no-cache libmcrypt-dev libxml2-dev libzip-dev icu icu-dev tzdata \
    && apk add --no-cache --virtual .build-deps g++ make \
    && apk add --no-cache git \
    # 修改 www-data uid=1000 gid=1001，只改一次
    && usermod --uid 1000 www-data \
    && groupmod --gid 1001 www-data \    
    && php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer

# PECL 扩展
RUN pecl install redis-6.3.0 \
    && docker-php-ext-enable redis \
    && pecl install trader-0.5.1 \
    && docker-php-ext-enable trader

# 内置扩展
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) bcmath exif gd intl mysqli pdo_mysql opcache sockets soap zip

# 时区设置
RUN cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && echo "${TIMEZONE}" > /etc/timezone

# PHP Ldap
# RUN apk add ldb-dev libldap openldap-dev && docker-php-ext-install -j$(nproc) ldap

# For Linux
# RUN usermod -u 1000 www-data

# For Mac
# RUN usermod -u 1000 www-data && usermod -G staff www-data

# Use the default production configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
#COPY "./php/php.ini" "$PHP_INI_DIR/php.ini"

# 安全配置 ini（追加）
RUN { \
    echo 'session.upload_progress.enabled=0'; \
    echo 'disable_functions=system,exec,passthru,shell_exec,proc_open,popen'; \
    echo 'opcache.enable=1'; \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.max_accelerated_files=10000'; \
    echo 'opcache.revalidate_freq=60'; \
} > "$PHP_INI_DIR/conf.d/security.ini"

# 清理构建依赖，shadow 也删掉
RUN rm -fr /tmp/pear \
    && apk del linux-headers .build-deps freetype-dev libpng-dev libjpeg-turbo-dev icu-dev tzdata shadow

# COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# ✅ 关键：切换非root用户启动 php-fpm
USER www-data
