# 环境变量
- GLANCE_DB: glance数据库IP
- GLANCE_DBPASS： glance数据库密码
- KEYSTONE_INTERNAL_ENDPOINT: keystone internal endpoint
- KEYSTONE_ADMIN_ENDPOINT: keystone admin endpoint
- GLANCE_PASS: openstack glance用户 密码

# volumes:
- /opt/openstack/glance/: /etc/glance/
- /opt/openstack/log/glance/: /var/log/glance/
- /opt/openstack/images/: /var/lib/glance/images/
- /etc/ceph: /etc/ceph

# 启动glance
```bash
docker run -d --name glance-api -p 9292:9292 \
    -v /opt/openstack/glance/:/etc/glance/ \
    -v /opt/openstack/log/glance/:/var/log/glance/ \
    -v /opt/openstack/images/:/var/lib/glance/images/ \
    -v /etc/ceph:/etc/ceph \
    -e GLANCE_DB=10.64.0.52 \
    -e GLANCE_DBPASS=123456 \
    -e KEYSTONE_INTERNAL_ENDPOINT=10.64.0.52 \
    -e KEYSTONE_ADMIN_ENDPOINT=10.64.0.52 \
    -e GLANCE_PASS=glance \
    --entrypoint=/bin/bash \
    10.64.0.50:5000/lzh/glance:kilo
```

# 使用ceph作backend
编辑/etc/glance/glance-api.conf
```bash
[glance_store]
default_store = file
```