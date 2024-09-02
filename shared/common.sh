# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

# Common code to get settings

if test -f $HOME/.config/vespa/docker-setups
then
    # get default values, e.g.
    # CONTAINER_SUFFIX="-mac"
    # DOMAIN_SUFFIX=".internal"
    # CONTAINER_NETWORK=default
    # CONTAINER_ENGINE=podman
    # VOLUMESBASE=
    . $HOME/.config/vespa/docker-setups
fi

if test -z "$CONTAINER_ENGINE"
then
    if test -f /opt/homebrew/bin/podman -o -f /usr/local/bin/podman
    then
	CONTAINER_ENGINE=podman
    else
	CONTAINER_ENGINE=docker
    fi
fi

case "$CONTAINER_ENGINE" in
    podman|docker) ;;
    *) echo "Unknown container engine $CONTAINER_ENGINE" 1>&2
       exit 1;;
esac

test -n "$CONTAINER_SUFFIX" || CONTAINER_SUFFIX="-mac"
test -n "$DOMAIN_SUFFIX" || DOMAIN_SUFFIX=".internal"
test -n "$CONTAINER_NETWORK" || CONTAINER_NETWORK=default
