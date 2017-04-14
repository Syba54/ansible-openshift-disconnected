#!/bin/sh
POD_NAME=`/bin/kubectl -n storage get pods -l glusterfs=heketi-pod -o template --template='{{ range .items }} {{ .metadata.name }}{{ end }}'`

/bin/kubectl -n storage exec -t -i $POD_NAME -- mkdir -p /root/git/gluster-kubernetes/deploy
/bin/kubectl -n storage cp /root/git/gluster-kubernetes/deploy/topology.json $POD_NAME:/root/git/gluster-kubernetes/deploy/topology.json

/bin/kubectl -n storage exec -t -i $POD_NAME -- heketi-cli $*
