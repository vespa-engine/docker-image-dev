#!/bin/sh
# Copyright Yahoo. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

docker container rm -f $USER-testrunner
docker container rm -f $USER-configserver
docker service rm $USER-vespanode
docker network rm $USER-vespa
