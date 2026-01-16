#!/usr/bin/env bash
# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.
#
set -o errexit
set -o nounset
set -o pipefail

if [[ "${DEBUG:-no}" == "true" ]]; then
    set -o xtrace
fi

if podman -v; then
    engine=podman
else
    engine=docker
fi

IDENT=${1-"0"}
ALMALINUX_VERSION=9
FORWARD_SSH_PORT=$((3900 + 10 * ${ALMALINUX_VERSION} + ${IDENT}))

cname="vespa-almalinux-${ALMALINUX_VERSION}"
container_name="${cname}-dev-${IDENT}"

img="docker.io/vespaengine/vespa-dev-almalinux-${ALMALINUX_VERSION}:latest"
${engine} pull $img

vol="volume-${container_name}"
${engine} volume ls | grep -q $vol || ${engine} volume create $vol

network_name=vespa-testing
${engine} network ls | grep -q $network_name || ${engine} network create $network_name

myuname=$(id -un)

echo "Creating ${engine} container ${container_name}"
${engine} create \
        --privileged \
        -p 127.0.0.1:${FORWARD_SSH_PORT}:22 \
        -v ${vol}:/home/${myuname} \
        --name ${container_name} \
        --network ${network_name} \
        --hostname ${container_name}.vespa.local \
        ${img}

${engine} start ${container_name}

if [ -f etc.ssh.tar ]; then
    ${engine} exec -i ${container_name} tar -C / -xvpf - < etc.ssh.tar
fi

# Add your user if it does not exist already
${engine} exec -it ${container_name} bash -c "grep -q '^${myuname}:' /etc/passwd || useradd -s /bin/bash ${myuname}"

# Ensure your user has "sudo" rights
${engine} exec -it ${container_name} bash -c "echo ${myuname} 'ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers"

# Ensure home directory has correct owner and group
${engine} exec -it ${container_name} bash -c "chown -R ${myuname}:${myuname} /home/${myuname}"

# Ensure home directory has correct permissions
${engine} exec -it ${container_name} bash -c "chmod 755 /home/${myuname}"

# Copy authorized keys
${engine} exec -u "${myuname}" -it ${container_name} bash -c "mkdir -p /home/${myuname}/.ssh"

if test -f $HOME/.ssh/authorized_keys; then
    ${engine} cp -a $HOME/.ssh/authorized_keys ${container_name}:/home/${myuname}/.ssh/
elif test -f $HOME/.ssh/id_rsa.pub; then
    ${engine} cp -a $HOME/.ssh/id_rsa.pub ${container_name}:/home/${myuname}/.ssh/authorized_keys
elif test -f $HOME/.ssh/id_ed25519.pub; then
    ${engine} cp -a $HOME/.ssh/id_ed25519.pub ${container_name}:/home/${myuname}/.ssh/authorized_keys
else
    echo "ERROR: No authorized keys found in $HOME/.ssh"
    exit 1
fi
${engine} exec -it ${container_name} bash -c "chown ${myuname}:${myuname} /home/${myuname}/.ssh/authorized_keys"

if [ $(arch) = arm64 ] || [ $(arch) = aarch64 ]; then
    mvn_options="-Xms128m -Xmx2g -XX:UseSVE=0"
else
    mvn_options="-Xms128m -Xmx2g -XX:UseSVE=0"
fi

echo "Creating .${engine}_profile with appropriate environment variables"
# Set environment variables
${engine} exec -u "${myuname}" -it ${container_name} bash -c \
	"printf \"%s\n\" \
	'export VESPA_HOME=\$HOME/vespa' \
	'PATH=\$PATH:\$HOME/bin:\$VESPA_HOME/bin:\$HOME/git/system-test/bin:/opt/vespa-deps/bin' \
	'export PATH' \
	'export JAVA_HOME='\`echo /usr/lib/jvm/java-21-openjdk-*\` \
	'export MAVEN_OPTS=\"${mvn_options}\"' \
	> ~/.${engine}_profile; cat ~/.${engine}_profile"

${engine} exec -u "${myuname}" -it ${container_name} bash -c \
        "grep -q '.${engine}_profile' ~/.bash_profile || echo 'test -f ~/.${engine}_profile && source ~/.${engine}_profile || true' >> ~/.bash_profile"

# Ensure home directory has correct owner and group (again)
${engine} exec -it ${container_name} bash -c "chown -R ${myuname}:${myuname} /home/${myuname}"

# Adjust ccache max size
${engine} exec -u "${myuname}" -it ${container_name} bash -c "ccache -M 20G"

if grep -q "Host $container_name" ~/.ssh/config; then
    echo "Host $container_name already exists in ~/.ssh/config - not adding it again"
else
    echo "Adding Host $container_name in your ~/.ssh/config redirecting via 127.0.0.1"
    (
	echo ""
	echo "Host $container_name"
	echo "        Hostname 127.0.0.1"
        echo "        Port ${FORWARD_SSH_PORT}"
    ) >> ~/.ssh/config
fi

echo "Trying to connect to $container_name via ssh..."
gothn=$(ssh -o 'StrictHostKeyChecking accept-new' $container_name hostname)
if [ "$gothn" = ${container_name}.vespa.local ]; then
	echo "SSH connection OK"
	if ! [ -f etc.ssh.tar ]; then
		echo "Saving generated host keys"
		ssh $container_name sudo tar -C / -cf - '/etc/ssh/ssh_host_*' > etc.ssh.tar
	fi
fi
echo "Logging in on new ${engine} container $container_name ..."
ssh $container_name
