FROM php:apache
MAINTAINER Viktor Farcic "viktor@farcic.com"

RUN apt-get update && \
    apt-get install -y openssh-client && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/.ssh

COPY index.php /var/www/html/index.php

ENV USER john
ENV PASSWORD doe

EXPOSE 80