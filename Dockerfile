# image name lzh/glance-api:kilo
FROM 10.64.0.50:5000/lzh/openstackbase:kilo

MAINTAINER Zuhui Liu penguin_tux@live.com

ENV BASE_VERSION 2015-08-12
ENV OPENSTACK_VERSION kilo


ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get dist-upgrade -y && apt-get install glance-api python-ceph -y && apt-get clean

RUN env --unset=DEBIAN_FRONTEND

RUN cp -rp /etc/glance/ /glance
RUN rm -rf /etc/glance/*
RUN rm -rf /var/log/glance/*

VOLUME ["/etc/glance"]
VOLUME ["/var/log/glance"]
VOLUME ["/var/lib/glance/images/"]
VOLUME ["/etc/ceph/"]

ADD entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

ADD glance-api.conf /etc/supervisor/conf.d/glance-api.conf

EXPOSE 9292

ENTRYPOINT ["/usr/bin/entrypoint.sh"]