#!/bin/sh
# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

# Run vespanode as service task using docker swarm.
echo "Run vespanode start, arguments are $NODE_SERVER_OPTS"

vespa-remove-index -force && echo indexes removed
vespa-configserver-remove-state -force
echo "Initial cleanup done"

if sudo -n echo non-interactive sudo works
then
    fixup_owner()
    {
	sudo -n chown $(id -u):$(id -g) $1
    }
else
    fixup_owner()
    {
	echo no fixup owner for $1 due to non-interactive sudo not working
    }
fi

fixup_dir()
{
    test -O $1 || fixup_owner $1
    test -O $1 && chmod $2 $1
}

# Workaround for tmpfs-mode not working for docker service mounts.
# Default seems to be existing mode in underlying directory.
fixup_dir vespa/logs/systemtests 1777
fixup_dir vespa/logs/vespa 1777
fixup_dir vespa/tmp/vespa 1777
fixup_dir vespa/tmp/systemtests 1777
fixup_dir vespa/var/db/vespa 1777
fixup_dir vespa/var/jdisc_container 1777
fixup_dir vespa/var/vespa 1777
fixup_dir vespa/var/zookeeper 1777

nodeserver.sh $NODE_SERVER_OPTS
