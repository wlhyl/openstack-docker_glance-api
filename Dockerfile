# image name lzh/glance-api:kilo
FROM registry.lzh.site:5000/lzh/openstackbase:kilo

MAINTAINER Zuhui Liu penguin_tux@live.com

ENV BASE_VERSION 2015-08-12
ENV OPENSTACK_VERSION kilo


ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get -t jessie-backports install glance-api curl -y
RUN apt-get clean

RUN env --unset=DEBIAN_FRONTEND

RUN cp -rp /etc/glance/ /glance
RUN rm -rf /etc/glance/*
RUN rm -rf /var/log/glance/*

RUN mv /glance/schema-image.json /glance/schema-image.json.orig
RUN curl http://git.openstack.org/cgit/openstack/glance/plain/etc/schema-image.json?h=stable/kilo \
         -o /glance/schema-image.json

VOLUME ["/etc/glance"]
VOLUME ["/var/log/glance"]
VOLUME ["/var/lib/glance/images/"]

ADD entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

ADD glance-api.conf /etc/supervisor/conf.d/glance-api.conf

EXPOSE 9292

ENTRYPOINT ["/usr/bin/entrypoint.sh"]