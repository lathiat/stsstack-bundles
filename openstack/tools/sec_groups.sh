#!/bin/bash -ex
# Add sec groups for basic access
`env| egrep -q "^OS_.*DOMAIN.*|/v3"` && v3args="--project-domain admin_domain" || v3args=""
secgroup=${1:-`openstack security group show default -f value -c id`}

openstack security group rule create $secgroup --protocol any --ethertype IPv4
openstack security group rule create $secgroup --protocol any --ethertype IPv6
