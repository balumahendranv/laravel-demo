FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    apache2 \
    mysql-server \
    git \
    unzip \
    curl \
    vim \
    software-properties-common \
    lsb-release \
    gnupg2 \
    ca-certificates

# Install PHP 8.3 and extensions
RUN add-apt-repository ppa:ondrej/php -y && apt-get update && apt-get install -y \
    php8.3 \
    php8.3-cli \
    php8.3-common \
    php8.3-mysql \
    php8.3-xml \
    php8.3-mbstring \
    php8.3-curl \
    php8.3-zip \
    php8.3-bcmath \
    php8.3-intl \
    php8.3-sqlite3 \
    libapache2-mod-php8.3

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --ignore-platform-req=ext-pdo_sqlite

# Set working directory to Laravel app location
WORKDIR /var/www/html/laravel-demo

# Copy all project files into the container
COPY . .

# Laravel setup
RUN cp .env.example .env \
    && composer install --no-interaction --prefer-dist \
    && php artisan key:generate \
    && chmod -R 777 storage bootstrap/cache

# Enable Apache mod_rewrite and update virtual host config
RUN a2enmod rewrite && cp apache-vhost.conf /etc/apache2/sites-available/000-default.conf

# Create MySQL socket directory
RUN mkdir -p /var/run/mysqld && chown mysql:mysql /var/run/mysqld

# Ensure the startup script is executable
RUN chmod +x start.sh

# Expose ports for Apache and MySQL
EXPOSE 80 3306

# Run the startup script
CMD ["./start.sh"]
