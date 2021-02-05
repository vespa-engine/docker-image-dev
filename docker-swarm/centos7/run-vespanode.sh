#!/bin/sh
# Copyright Verizon Media. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

# Run vespanode as service task using docker swarm.
echo "Run vespanode start, arguments are $NODE_SERVER_OPTS"

. ./.bash_profile
test -f .bashrc && . ./.bashrc

vespa-remove-index -force && echo indexes removed
vespa-configserver-remove-state -force
echo "Initial cleanup done"

nodeserver.sh $NODE_SERVER_OPTS
