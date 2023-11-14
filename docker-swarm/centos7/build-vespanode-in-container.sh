#!/bin/sh -ex
# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

# Build image for running vespa system tests using docker swarm.

echo "Make vespanode image start"

cd

test -f /mnt/.bashrc && rsync -aHvSx /mnt/.bashrc .bashrc
rsync -aHvSx /mnt/.bash_profile .bash_profile
if test -f /mnt/.docker_profile
then
    rsync -aHvSx /mnt/.docker_profile .docker_profile
fi
mkdir -p bin
test -d /mnt/bin && rsync -aHvSx --delete --exclude /run-vespanode.sh /mnt/bin/ bin/
rsync -aHvSx /mnt2/run-vespanode.sh bin/run-vespanode.sh
rsync -aHvSx --exclude /conf/vespa/tls/ /mnt/vespa/ vespa/
test -d /mnt/.vespa && rsync -aHvSx /mnt/.vespa/ .vespa/
mkdir -p git
rsync -aHvSx --delete --exclude /.git/ /mnt/git/system-test/ git/system-test/
rsync -aHvSx --delete /mnt/.m2/ .m2/

set +x
set +e
. ./.bash_profile
test -f .bashrc && . ./.bashrc
set -e
set -x
vespa-remove-index -force && echo indexes removed
vespa-configserver-remove-state -force

# Auto generate cert and key
if ! test -d .vespa
then
    nodeserver.sh &
    PID=$!
    sleep 3
    kill -9 $PID
fi

if ! test -d vespa/conf/vespa/tls
then
    # Setup the Vespa TLS config
    mkdir -p vespa/conf/vespa/tls
    cat << EOF > vespa/conf/vespa/tls/tls_config.json
{
    "disable-hostname-validation": true,
    "files": {
        "ca-certificates": "/home/$USER/vespa/conf/vespa/tls/ca.pem",
        "certificates": "/home/$USER/vespa/conf/vespa/tls/host.pem",
        "private-key": "/home/$USER/vespa/conf/vespa/tls/host.key"
    }
}
EOF
    cp -a .vespa/system_test_certs/ca.pem vespa/conf/vespa/tls
    cp -a .vespa/system_test_certs/host.pem vespa/conf/vespa/tls
    cp -a .vespa/system_test_certs/host.key vespa/conf/vespa/tls
fi

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
