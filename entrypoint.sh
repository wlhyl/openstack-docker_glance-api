#!/bin/bash

if [ -z "$GLANCE_DBPASS" ];then
  echo "error: GLANCE_DBPASS not set"
  exit 1
fi

if [ -z "$GLANCE_DB" ];then
  echo "error: GLANCE_DB not set"
  exit 1
fi

if [ -z "$GLANCE_PASS" ];then
  echo "error: GLANCE_PASS not set"
  exit 1
fi

if [ -z "$KEYSTONE_INTERNAL_ENDPOINT" ];then
  echo "error: KEYSTONE_INTERNAL_ENDPOINT not set"
  exit 1
fi

if [ -z "$KEYSTONE_ADMIN_ENDPOINT" ];then
  echo "error: KEYSTONE_ADMIN_ENDPOINT not set"
  exit 1
fi

CRUDINI='/usr/bin/crudini'

CONNECTION=mysql://glance:$GLANCE_DBPASS@$GLANCE_DB/glance

if [ ! -f /etc/glance/.complete ];then
    cp -rp /glance/* /etc/glance
    chown glance:glance /var/lib/glance/images/
    
    $CRUDINI --set /etc/glance/glance-api.conf database connection $CONNECTION

    $CRUDINI --del /etc/glance/glance-api.conf keystone_authtoken
    $CRUDINI --set /etc/glance/glance-api.conf keystone_authtoken auth_uri http://$KEYSTONE_INTERNAL_ENDPOINT:5000
    $CRUDINI --set /etc/glance/glance-api.conf keystone_authtoken auth_url http://$KEYSTONE_ADMIN_ENDPOINT:35357
    $CRUDINI --set /etc/glance/glance-api.conf keystone_authtoken auth_plugin password
    $CRUDINI --set /etc/glance/glance-api.conf keystone_authtoken project_domain_id default
    $CRUDINI --set /etc/glance/glance-api.conf keystone_authtoken user_domain_id default
    $CRUDINI --set /etc/glance/glance-api.conf keystone_authtoken project_name service
    $CRUDINI --set /etc/glance/glance-api.conf keystone_authtoken username glance
    $CRUDINI --set /etc/glance/glance-api.conf keystone_authtoken password $GLANCE_PASS
    
    $CRUDINI --set /etc/glance/glance-api.conf paste_deploy flavor keystone
    
    $CRUDINI --set /etc/glance/glance-api.conf glance_store default_store file
    $CRUDINI --set /etc/glance/glance-api.conf glance_store filesystem_store_datadir /var/lib/glance/images/
    $CRUDINI --del /etc/glance/glance-api.conf glance_store filesystem_store_datadirs
    
    $CRUDINI --set /etc/glance/glance-api.conf DEFAULT notification_driver noop
    
    $CRUDINI --set /etc/glance/glance-api.conf DEFAULT enable_v1_api False
    $CRUDINI --set /etc/glance/glance-api.conf DEFAULT enable_v2_api True

    touch /etc/glance/.complete
fi

chown -R glance:glance /var/log/glance/

# 同步数据库
echo 'select * from images limit 1;' | mysql -h$GLANCE_DB  -uglance -p$GLANCE_DBPASS glance
if [ $? != 0 ];then
    su -s /bin/sh -c "glance-manage db_sync" glance
fi

/usr/bin/supervisord -n