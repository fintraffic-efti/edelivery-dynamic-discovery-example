FROM ubuntu:24.04 AS build

# https://www.techtutorials.tv/sections/docker/build-your-own-bind9-docker-image/

USER root

RUN apt-get -qqy update \
    && apt-get -qqy install bind9 bind9utils bind9-doc

# Create the directory for the PID file and ensure bind user can write to it
RUN mkdir -p /run/named && chown bind:bind /run/named

EXPOSE 53/tcp
EXPOSE 53/udp

USER bind:bind

# https://bind9.readthedocs.io/en/v9.18.39/manpages.html#named-internet-domain-name-server
CMD ["/usr/sbin/named", "-g"]
