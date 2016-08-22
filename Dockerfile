FROM ubuntu:15.04
MAINTAINER Ludwring Liccien <ludwring.liccien@gmail.com>

ENV DEBIAN_FRONTEND noninteractive 
ENV TERM xterm

# Update the package repository  and Install base packages
RUN apt-get update && apt-get upgrade --yes && \
    apt-get install --yes nano wget curl sqlite3 && \
    apt-get install --yes apache2 supervisor && \
    apt-get install --yes \
        php-pear        \
        php5-cli        \
        php5-common     \
        php5-curl       \
        php5-dev        \
        php5-fpm        \
        php5-gd         \
        php5-imagick    \
        php5-imap       \
        php5-intl       \
        php5-json       \
        php5-ldap       \
        php5-mcrypt     \
        php5-memcache   \
        php5-mysql      \
        php5-mongo      \
        php5-redis      \
        php5-sqlite     \
        php5-tidy       \
        php5-xdebug     \
        php5-xhprof     \
        libapache2-mod-php5   && \
        pecl install uploadprogress


# Install Composer
RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

# Install Drush
RUN wget http://files.drush.org/drush.phar && chmod +x drush.phar && mv drush.phar /usr/local/bin/drush

# Install Drupal-Console
RUN curl https://drupalconsole.com/installer -L -o drupal.phar && mv drupal.phar /usr/local/bin/drupal && chmod +x /usr/local/bin/drupal

# Install Symfony Installer
RUN curl -LsS https://symfony.com/installer -o /usr/local/bin/symfony && chmod a+x /usr/local/bin/symfony 

# Cleaning
RUN apt-get -y autoremove && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#### config Xdebug
RUN sed -i '$ a\xdebug.var_display_max_depth=4' /etc/php5/mods-available/xdebug.ini && \
    sed -i '$ a\xdebug.max_nesting_level=500' /etc/php5/mods-available/xdebug.ini && \
    sed -i '$ a\xdebug.var_display_max_data=-1' /etc/php5/mods-available/xdebug.ini && \
    sed -i '$ a\xdebug.remote_enable=1' /etc/php5/mods-available/xdebug.ini && \
    sed -i '$ a\xdebug.remote_port="9000"' /etc/php5/mods-available/xdebug.ini 

# Confugure php.ini apache
RUN sed -ri 's/^max_execution_time\s*=\s*30/max_execution_time = 3600/g' /etc/php5/apache2/php.ini && \
    sed -ri 's/^display_errors\s*=\s*Off/display_errors = On/g' /etc/php5/apache2/php.ini && \ 
    sed -ri 's/^;date.timezone\s*=/date.timezone = UTC/g' /etc/php5/apache2/php.ini && \
    sed -ri 's/^memory_limit\s*=\s*128M/memory_limit = 1024M/g' /etc/php5/apache2/php.ini && \
    sed -ri 's/^post_max_size\s*=\s*8M/post_max_size = 2048M/g' /etc/php5/apache2/php.ini && \
    sed -ri 's/^upload_max_filesize\s*=\s*2M/upload_max_filesize = 2048M/g' /etc/php5/apache2/php.ini && \
    echo 'extension=uploadprogress.so' >> /etc/php5/apache2/php.ini

# Confugure php.ini php Cli
RUN sed -ri 's/^max_execution_time\s*=\s*30/max_execution_time = 3600/g' /etc/php5/cli/php.ini && \
    sed -ri 's/^display_errors\s*=\s*Off/display_errors = On/g' /etc/php5/cli/php.ini && \
    sed -ri 's/^;date.timezone\s*=/date.timezone = UTC/g' /etc/php5/cli/php.ini && \
    sed -ri 's/^memory_limit\s*=\s*128M/memory_limit = 1024M/g' /etc/php5/cli/php.ini && \
    sed -ri 's/^post_max_size\s*=\s*8M/post_max_size = 2048M/g' /etc/php5/cli/php.ini && \
    sed -ri 's/^upload_max_filesize\s*=\s*2M/upload_max_filesize = 2048M/g' /etc/php5/cli/php.ini


#### config apache RUN a2enmod rewrite 

RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf && a2enmod rewrite php5

COPY apache2.conf /etc/apache2/apache2.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN rm -rf /var/www/html && mkdir -p /var/lock/apache2 /var/run/apache2 /var/log/apache2 /var/www/html /var/log/supervisor && chown -R www-data:www-data /var/lock/apache2 /var/run/apache2 /var/log/apache2 /var/www/html /var/log/supervisor

# install libxrender1 for wkhtmltopdf
RUN apt-get update && apt-get install libxrender1 --yes

# Override Enabled ENV Variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

WORKDIR /var/www/html

RUN usermod -u 1000 www-data

EXPOSE 80
CMD ["/usr/bin/supervisord"]

