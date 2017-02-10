FROM        registry.access.redhat.com/redhat-sso-7/sso70-openshift:1.3
MAINTAINER  Samuel Terburg <sterburg@redhat.com>

ENV container docker

LABEL Vendor="Red Hat" License=GPLv2
LABEL Version=1.0
LABEL INSTALL="docker run --rm --privileged -u 0 -v /:/host -e HOST=/host -e DATADIR=/var/lib/\${NAME}/data -e IMAGE=\${IMAGE} -e NAME=\${NAME} \${IMAGE} bash /bin/install.sh"
LABEL UNINSTALL="docker run --rm --privileged -u 0 -v /:/host -e HOST=/host -e IMAGE=\${IMAGE} -e NAME=\${NAME} \${IMAGE} bash /bin/uninstall.sh"

ADD *.sh /bin/
ADD *.service /etc/systemd/system/
