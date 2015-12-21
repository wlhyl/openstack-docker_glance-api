# image name lzh/glance-api:liberty
FROM 10.64.0.50:5000/lzh/openstackbase:liberty

MAINTAINER Zuhui Liu penguin_tux@live.com

ENV BASE_VERSION 2015-12-21
ENV OPENSTACK_VERSION liberty

RUN yum update -y
RUN yum install -y openstack-glance python-glance python-glanceclient
RUN yum clean all
RUN rm -rf /var/cache/yum/*

RUN cp -rp /etc/glance/ /glance
RUN rm -rf /etc/glance/*
RUN rm -rf /var/log/glance/*

VOLUME ["/etc/glance"]
VOLUME ["/var/log/glance"]
VOLUME ["/var/lib/glance/images/"]
VOLUME ["/etc/ceph/"]

ADD entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

ADD glance-api.ini /etc/supervisord.d/glance-api.ini

EXPOSE 9292

ENTRYPOINT ["/usr/bin/entrypoint.sh"]