#!/bin/sh -x
eval $*
NAME=${NAME:-rhsso}
HOST=${HOST:-/host}
#LOGDIR=${LOGDIR:-/var/log/${NAME}}
#CONFDIR=${CONFDIR:-/etc/${NAME}}
DATADIR=${DATADIR:-/var/lib/pgsql/data}
IMAGE=${IMAGE:-registry.access.redhat.com/redhat-sso-7/sso70-openshift}
POSTGRESQL_IMAGE=${POSTGRESQL_IMAGE:-registry.access.redhat.com/openshift3/postgresql-92-rhel7}
POSTGRESQL_USER=${POSTGRESQL_USER:-rhssousr}
POSTGRESQL_PASSWORD=${POSTGRESQL_PASSWORD:-rhssopwd}
POSTGRESQL_DATABASE=${POSTGRESQL_DATABASE:-rhssodb}
APP_POSTGRESQL_SERVICE_HOST=${APP_POSTGRESQL_SERVICE_HOST:-localhost}
APP_POSTGRESQL_SERVICE_PORT=${APP_POSTGRESQL_SERVICE_PORT:-5432}
SSO_ADMIN_PASSWORD=${SSO_ADMIN_PASSWORD:-secret}
JGROUPS_CLUSTER_PASSWORD=${JGROUPS_CLUSTER_PASSWORD:-$POSTGRESQL_PASSWORD}
POSTGRESQL_MEMORY=${POSTGRESQL_MEMORY:-2g}
RHSSO_MEMORY=${RHSSO_MEMORY:-2g}


# Make Data Dirs
mkdir -m 0777 -p ${HOST}/${DATADIR}
#                ${HOST}/${LOGDIR}a \
#                ${HOST}/${CONFDIR}
  
# Copy Config
# cp -pR /etc/rhsso ${HOST}/${CONFDIR}

# Create Container
chroot ${HOST} /usr/bin/docker create --name ${NAME}-db \
                                      -p ${APP_POSTGRESQL_SERVICE_PORT}:${APP_POSTGRESQL_SERVICE_PORT} \
                                      -m ${POSTGRESQL_MEMORY} \
                                      -v ${DATADIR}:/var/lib/pgsql/data:Z \
                                      -v /dev/shm:/dev/shm:Z \
                                      -e POSTGRESQL_USER=${POSTGRESQL_USER} \
                                      -e POSTGRESQL_PASSWORD=${POSTGRESQL_PASSWORD} \
                                      -e POSTGRESQL_DATABASE=${POSTGRESQL_DATABASE} \
                                      ${POSTGRESQL_IMAGE} 
chroot ${HOST} /usr/bin/docker create --name ${NAME} \
                                      -p 8080:8080 \
                                      -m ${RHSSO_MEMORY} \
                                      -e DB_JNDI=java:jboss/datasources/KeycloakDS \
                                      -e OPENSHIFT_KUBE_PING_NAMESPACE=default \
                                      -e JGROUPS_CLUSTER_PASSWORD=${JGROUPS_PASSWORD} \
                                      -e DB_USERNAME=${POSTGRESQL_USER} \
                                      -e DB_PASSWORD=${POSTGRESQL_PASSWORD} \
                                      -e DB_DATABASE=${POSTGRESQL_DATABASE} \
                                      -e DB_SERVICE_PREFIX_MAPPING=app-postgresql=DB \
                                      -e TX_DATABASE_PREFIX_MAPPING-postgresql=DB \
                                      -e APP_POSTGRESQL_SERVICE_HOST=${APP_POSTGRESQL_SERVICE_HOST} \
                                      -e APP_POSTGRESQL_SERVICE_PORT=${APP_POSTGRESQL_SERVICE_PORT} \
                                      -e SSO_ADMIN_PASSWORD=${SSO_ADMIN_PASSWORD} \
                                      ${IMAGE} 

# Install systemd unit file for running container
sed -e "s/TEMPLATE/${NAME}/g" /etc/systemd/system/rhsso-db.service > ${HOST}/etc/systemd/system/${NAME}-db.service
sed -e "s/TEMPLATE/${NAME}/g" /etc/systemd/system/rhsso.service    > ${HOST}/etc/systemd/system/${NAME}.service
chroot ${HOST} systemctl daemon-reload

# Enabled systemd unit file
chroot ${HOST} /usr/bin/systemctl enable ${NAME}-db.service
chroot ${HOST} /usr/bin/systemctl enable ${NAME}.service

# Start service
chroot ${HOST} /usr/bin/systemctl start ${NAME}-db.service
chroot ${HOST} /usr/bin/systemctl start ${NAME}.service
