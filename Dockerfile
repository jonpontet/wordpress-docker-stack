# Dockerfile
# Defines an image.
# Rebuild this image: docker build -t my-php-8.2-apache:latest .

FROM php:8.2-apache

# Install packages.
RUN apt-get update && apt-get install -y \
    vim \
    unzip \
    libcurl4 \
    libcurl4-openssl-dev \
    git \
    libzip-dev \
    zlib1g-dev

RUN pecl install igbinary

# Install PHP extensions.
RUN docker-php-ext-install mysqli \
    && docker-php-ext-install opcache \
    && docker-php-ext-install curl \
    && docker-php-ext-install exif \
    && docker-php-ext-install zip

# Enable PHP extensions
RUN docker-php-ext-enable igbinary

# Install composer 2.2.
RUN curl https://getcomposer.org/installer > composer-setup.php && php composer-setup.php --2.2
RUN chmod a+x composer.phar && mv composer.phar /usr/local/bin/composer

# Enable SSL for Apache.
RUN a2enmod ssl

# Enable mod_rewrite for Apache.
RUN a2enmod rewrite

# Enable xDebug.
# https://www.jetbrains.com/help/phpstorm/configuring-xdebug.html#configuring-xdebug-docker
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && echo "xdebug.mode=off" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.idekey=php:8.2-apache" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_host = host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Necessary?
#RUN ssh-keyscan -t rsa gitlab.com >> ~/.ssh/known_hosts

# Turn off git strict host checking to avoid clone failures.
RUN export GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"