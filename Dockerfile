FROM ubuntu:14.04.4
MAINTAINER Ludwring Liccien <ludwring.liccien@gmail.com>

# Update the package repository 
ENV DEBIAN_FRONTEND noninteractive 
RUN apt-get update && apt-get upgrade --yes

# Install base packages
RUN apt-get install --yes nano wget curl sqlite3
RUN apt-get install --yes apache2 supervisor
RUN rm -rf /var/www/html && mkdir -p /var/lock/apache2 /var/run/apache2 /var/log/apache2 /var/www/html && chown -R www-data:www-data /var/lock/apache2 /var/run/apache2 /var/log/apache2 /var/www/html
RUN apt-get install --yes php5 php5-common php5-cli php5-intl php5-gd php5-curl php5-mysql php5-xdebug  php5-cgi php5-fpm php-pear php5-dev php5-mcrypt php5-xmlrpc libapache2-mod-php5 
RUN pecl install uploadprogress


# Install Composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# Install Drush
RUN wget http://files.drush.org/drush.phar
RUN chmod +x drush.phar
RUN sudo mv drush.phar /usr/local/bin/drush

# Install Drupal-Console
RUN curl https://drupalconsole.com/installer -L -o drupal.phar
RUN mv drupal.phar /usr/local/bin/drupal
RUN chmod +x /usr/local/bin/drupal

# Install Symfony Installer
RUN curl -LsS https://symfony.com/installer -o /usr/local/bin/symfony
RUN chmod a+x /usr/local/bin/symfony 

# Cleaning
RUN apt-get -y autoremove && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#### config php RUN sed -i '$ a\xdebug.var_display_max_depth=4' /etc/php5/mods-available/xdebug.ini
RUN sed -i '$ a\xdebug.max_nesting_level=500' /etc/php5/mods-available/xdebug.ini
RUN sed -i '$ a\xdebug.var_display_max_data=-1' /etc/php5/mods-available/xdebug.ini
RUN sed -i '$ a\xdebug.remote_enable=1' /etc/php5/mods-available/xdebug.ini
RUN sed -i '$ a\xdebug.remote_port="9000"' /etc/php5/mods-available/xdebug.ini

# Configure OpCache
RUN sed -i '$ a\opcache.max_accelerated_files=20000' /etc/php5/mods-available/opcache.ini
RUN sed -i '$ a\opcache.interned_strings_buffer=8' /etc/php5/mods-available/opcache.ini
RUN sed -i '$ a\opcache.memory_consumption=384' /etc/php5/mods-available/opcache.ini
RUN sed -i '$ a\opcache.revalidate_freq=0' /etc/php5/mods-available/opcache.ini
RUN sed -i '$ a\opcache.validate_timestamps=0' /etc/php5/mods-available/opcache.ini
RUN sed -i '$ a\opcache.fast_shutdown=1' /etc/php5/mods-available/opcache.ini
RUN sed -i '$ a\opcache.enable_cli=0' /etc/php5/mods-available/opcache.ini
RUN sed -i '$ a\opcache.enable=1' /etc/php5/mods-available/opcache.ini

# Confugure php.ini apache
RUN sed -ri 's/^max_execution_time\s*=\s*30/max_execution_time = 3600/g' /etc/php5/apache2/php.ini
RUN sed -ri 's/^display_errors\s*=\s*Off/display_errors = On/g' /etc/php5/apache2/php.ini
RUN sed -ri 's/^;date.timezone\s*=/date.timezone = UTC/g' /etc/php5/apache2/php.ini
RUN sed -ri 's/^memory_limit\s*=\s*128M/memory_limit = 1024M/g' /etc/php5/apache2/php.ini
RUN sed -ri 's/^post_max_size\s*=\s*8M/post_max_size = 2048M/g' /etc/php5/apache2/php.ini
RUN sed -ri 's/^upload_max_filesize\s*=\s*2M/upload_max_filesize = 2048M/g' /etc/php5/apache2/php.ini

RUN echo 'extension=uploadprogress.so' >> /etc/php5/apache2/php.ini

# Confugure php.ini php Cli
RUN sed -ri 's/^max_execution_time\s*=\s*30/max_execution_time = 3600/g' /etc/php5/cli/php.ini
RUN sed -ri 's/^display_errors\s*=\s*Off/display_errors = On/g' /etc/php5/cli/php.ini
RUN sed -ri 's/^;date.timezone\s*=/date.timezone = UTC/g' /etc/php5/cli/php.ini
RUN sed -ri 's/^memory_limit\s*=\s*128M/memory_limit = 1024M/g' /etc/php5/cli/php.ini
RUN sed -ri 's/^post_max_size\s*=\s*8M/post_max_size = 2048M/g' /etc/php5/cli/php.ini
RUN sed -ri 's/^upload_max_filesize\s*=\s*2M/upload_max_filesize = 2048M/g' /etc/php5/cli/php.ini

RUN echo 'extension=uploadprogress.so' >> /etc/php5/cli/php.ini

#### config apache RUN a2enmod rewrite 

RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf 

RUN a2enmod rewrite

COPY apache2.conf /etc/apache2/apache2.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ENV TERM xterm
WORKDIR /var/www/html

EXPOSE 22 80
CMD ["/usr/bin/supervisord"]

