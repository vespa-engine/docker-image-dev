#!/usr/bin/env bash
# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.
#
set -o errexit
set -o nounset
set -o pipefail

if [[ "${DEBUG:-no}" == "true" ]]; then
    set -o xtrace
fi

echo "List of vespanode hosts:"
docker node ls  --filter "node.label=enable-$USER-vespanode=true" --format '{{.Hostname}}'
