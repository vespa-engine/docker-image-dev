#!/usr/bin/env bash
# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.
#
set -o errexit
set -o nounset
set -o pipefail

if [[ "${DEBUG:-no}" == "true" ]]; then
    set -o xtrace
fi

node=$1
NODELIST=$(docker node ls --format '{{.Hostname}}' | tr '\n' ' ')

for checknode in $NODELIST; do
    if test "$checknode" = "$node"
    then
	docker node update --label-rm enable-"$USER"-vespanode "$node"
	exit 0
    fi
done
echo "Bad node $node, not in list of known nodes: $NODELIST" 1>&2
exit 1
