FROM php:7.0.11-apache

MAINTAINER developers@synopsis.cz

RUN a2enmod rewrite
RUN a2enmod ssl
RUN a2ensite 000-default
RUN a2ensite default-ssl

ENV TZ Europe/Prague 

ENV DEPENDENCY_PACKAGES="libmcrypt-dev"
ENV BUILD_PACKAGES="cron supervisor ssl-cert"

RUN sed -i  "s/http:\/\/httpredir\.debian\.org\/debian/ftp:\/\/ftp\.debian\.org\/debian/g" /etc/apt/sources.list

RUN apt-get clean \
    && apt-get update \
    && apt-get install -y $DEPENDENCY_PACKAGES $BUILD_PACKAGES \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# php.ini
COPY conf/php.ini /usr/local/etc/php/

# cron
COPY cron /etc/pam.d/cron

# supervisor.conf
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/000-supervisord.conf

EXPOSE 80 443 9001

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
