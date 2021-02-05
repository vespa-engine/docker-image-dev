#!/bin/sh -ex
# Copyright Verizon Media. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

# Build image for running vespa system tests using docker swarm.

echo "Make vespanode image start"

cd

rsync -aHvSx /mnt/.bashrc .bashrc
rsync -aHvSx /mnt/.bash_profile .bash_profile
if test -f /mnt/.docker_profile
then
    rsync -aHvSx /mnt/.docker_profile .docker_profile
fi
rsync -aHvSx --delete --exclude /run-vespanode.sh /mnt/bin/ bin/
rsync -aHvSx /mnt2/run-vespanode.sh bin/run-vespanode.sh
rsync -aHvSx /mnt/vespa/ vespa/
rsync -aHvSx /mnt/.vespa/ .vespa/
mkdir -p git
rsync -aHvSx --delete --exclude /.git/ /mnt/git/system-test/ git/system-test/
rsync -aHvSx --delete /mnt/.m2/ .m2/

set +x
set +e
. ./.bash_profile
. ./.bashrc
set -e
set -x
vespa-remove-index -force && echo indexes removed
vespa-configserver-remove-state -force

# Workaround for tmpfs-mode not working for docker service mounts.
# Default seems to be existing mode in underlying directory.
mkdir -p vespa/logs/systemtests
chmod 1777 vespa/logs/systemtests || true
chmod 1777 vespa/logs/vespa || true
chmod 1777 vespa/tmp/vespa || true
mkdir -p vespa/tmp/systemtests
chmod 1777 vespa/tmp/systemtests || true
chmod 1777 vespa/var/db/vespa || true
mkdir -p vespa/var/jdisc_container
chmod 1777 vespa/var/jdisc_container || true
mkdir -p vespa/var/vespa
chmod 1777 vespa/var/vespa || true
chmod 1777 vespa/var/zookeeper || true

if test -f /mnt/git/system-test-feature-flags.json
then
  cp /mnt/git/system-test-feature-flags.json vespa/var/vespa/flag.db || true
fi

echo "Make vespanode image end"
