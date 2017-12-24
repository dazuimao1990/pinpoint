#!/bin/bash
set -e

[[ $DEBUG ]] && set -x

CLUSTER_ENABLE=${CLUSTER_ENABLE:-false}
CLUSTER_ZOOKEEPER_ADDRESS=${HBASE_HOST:-127.0.0.1}
ADMIN_PASSWORD=${ADMIN_PASSWORD:-admin}

HBASE_HOST=${HBASE_HOST:-127.0.0.1}
HBASE_PORT=${HBASE_PORT:-2181}

DISABLE_DEBUG=${DISABLE_DEBUG:-true}

JDBC_DRIVER=${JDBC_DRIVER:-com.mysql.jdbc.Driver}
JDBC_URL=${JDBC_URL:-jdbc:mysql://${MYSQL_HOST}:${MYSQL_PORT}/pinpoint?characterEncoding=UTF-8}
JDBC_USERNAME=${MYSQL_USER:-admin}
JDBC_PASSWORD=${MYSQL_PASS:-admin}

echo -e "
jdbc.driverClassName=${JDBC_DRIVER}
jdbc.url=${JDBC_URL}
jdbc.username=${JDBC_USERNAME}
jdbc.password=${JDBC_PASSWORD}
" > ${TOMCAT_PATH}/webapps/ROOT/WEB-INF/classes/jdbc.properties



sed -i -r -e "s/(cluster.enable)=true/\1=${CLUSTER_ENABLE}/g" \
          -e "s/(cluster.zookeeper.address)=localhost/\1=${CLUSTER_ZOOKEEPER_ADDRESS}/g" \
          -e "s/(admin.password)=admin/\1=${ADMIN_PASSWORD}/g" ${TOMCAT_PATH}/webapps/ROOT/WEB-INF/classes/pinpoint-web.properties

sed -i -r -e "s/(hbase.client.host)=localhost/\1=${HBASE_HOST}/g" \
          -e "s/(hbase.client.port)=2181/\1=${HBASE_PORT}/g" ${TOMCAT_PATH}/webapps/ROOT/WEB-INF/classes/hbase.properties

if [ "$DISABLE_DEBUG" == "true" ]; then
    sed -i -r 's/(level value)="DEBUG"/\1="INFO"/' ${TOMCAT_PATH}/webapps/ROOT/WEB-INF/classes/log4j.xml
fi

exec ${TOMCAT_PATH}/bin/catalina.sh run