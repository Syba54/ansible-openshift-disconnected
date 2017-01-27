#!/bin/sh -x
NAME=${NAME:-rhsso}
IMAGE=${IMAGE:-registry.access.redhat.com/redhat-sso-7/sso70-openshift}
POSTGRESQL_IMAGE=${IMAGE:-registry.access.redhat.com/openshift3/postgresql-92-rhel7}

chroot ${HOST} /usr/bin/systemctl stop    ${NAME}.service
chroot ${HOST} /usr/bin/systemctl stop    ${NAME}-db.service
chroot ${HOST} /usr/bin/systemctl disable ${NAME}.service
chroot ${HOST} /usr/bin/systemctl disable ${NAME}-db.service

rm -f ${HOST}/etc/systemd/system/${NAME}.service \
      ${HOST}/etc/systemd/system/${NAME}-db.service

chroot ${HOST} /usr/bin/docker rm -f ${NAME} \
                                     ${NAME}-db
chroot ${HOST} /usr/bin/docker rmi ${IMAGE} \
                                   ${POSTGRESQL_IMAGE}
