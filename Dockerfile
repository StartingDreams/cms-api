FROM php:7-apache

# Install basics
RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    libmcrypt-dev \
    git \
    zlib1g-dev \
    vim \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Basic lumen packages
RUN docker-php-ext-install \
        mcrypt \
        mbstring \
        zip

# Install mongodb drivers
RUN pecl install mongodb \
    && docker-php-ext-enable mongodb

# Install mysql php extension
RUN docker-php-ext-install pdo pdo_mysql

# Install redis from source
RUN git clone -b php7 https://github.com/phpredis/phpredis.git \
    && mv phpredis/ /etc/ \
    && cd /etc/phpredis \
    && phpize \
    && ./configure \
    && make && make install \
    && docker-php-ext-enable redis

# Remove default site
RUN  rm /etc/apache2/sites-available/000-default.conf

COPY config/apache/apache2.conf /etc/apache2/apache2.conf
COPY config/apache/sites /etc/apache2/sites-available

# Enable rewrite module
RUN a2enmod rewrite

# add artisan user
RUN useradd -m -u 1000 artisan

WORKDIR /var/www/html

# Download and Install Composer
RUN curl -s http://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

# Add vendor binaries to PATH
ENV PATH=/var/www/html/vendor/bin:$PATH
