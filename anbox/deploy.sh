#!/bin/sh
juju add-model anbox-controller
juju switch anbox-controller
juju deploy ./anbox-controller.yaml --overlay ua-anbox-controller.yaml --overlay overlay-anbox-controller-v22.yaml

juju add-model anbox-subcluster1
juju switch anbox-subcluster1
juju deploy ./anbox-subcluster.yaml --overlay ua-anbox-subcluster.yaml --overlay overlay-anbox-subcluster1.yaml --overlay overlay-anbox-subcluster-v22.yaml

#juju add-model anbox-subcluster2
#juju switch anbox-subcluster2
#juju deploy ./anbox-subcluster.yaml --overlay ua-anbox-subcluster.yaml --overlay anbox-subcluster2.yaml --overlay overlay-anbox-subcluster-v23.yaml

