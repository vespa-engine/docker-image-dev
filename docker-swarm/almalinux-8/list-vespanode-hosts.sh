#!/bin/sh
# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

echo "List of vespanode hosts:"
docker node ls  --filter "node.label=enable-$USER-vespanode=true" --format '{{.Hostname}}'
