#!/bin/sh

UBUNTU_VERSION=25.04
MAJOR_V=${UBUNTU_VERSION%.*}

container_name="vespa-ubuntu-dev-${MAJOR_V}"
img="vespa-ubuntu-dev:${UBUNTU_VERSION}"

vol="volume-${container_name}"
docker volume list | grep -q $vol || docker volume create $vol

network_name=vespa-testing
docker network list | grep -q $network_name || docker network create $network_name

myuname=$(id -un)

echo "Creating docker container ${container_name}"
docker create \
        --privileged \
        --pids-limit -1 \
        -p 127.0.0.1:39${MAJOR_V}:22 \
        -v ${vol}:/home/${myuname} \
        --ulimit nofile=450000:524288 \
        --shm-size 2G \
        --name ${container_name} \
        --network ${network_name} \
        --hostname ${container_name}.vespa.local \
        ${img}

docker start ${container_name}

if [ -f etc.ssh.tar ]; then
    docker exec -i ${container_name} tar -C / -xvpf - < etc.ssh.tar
fi

# Add your user if it does not exist already
docker exec -it ${container_name} bash -c "grep -q '^${myuname}:' /etc/passwd || useradd -s /bin/bash ${myuname}"

# Ensure home directory has correct owner and group
docker exec -it ${container_name} bash -c "chown -R ${myuname}:${myuname} /home/${myuname}"

# Ensure home directory has correct permissions
docker exec -it ${container_name} bash -c "chmod 755 /home/${myuname}"

# Copy authorized keys
docker exec -u "${myuname}" -it ${container_name} bash -c "mkdir -p /home/${myuname}/.ssh"

if test -f $HOME/.ssh/authorized_keys; then
    docker cp -a $HOME/.ssh/authorized_keys ${container_name}:/home/${myuname}/.ssh/
elif test -f $HOME/.ssh/id_rsa.pub; then
    docker cp -a $HOME/.ssh/id_rsa.pub ${container_name}:/home/${myuname}/.ssh/authorized_keys
elif test -f $HOME/.ssh/id_ed25519.pub; then
    docker cp -a $HOME/.ssh/id_ed25519.pub ${container_name}:/home/${myuname}/.ssh/authorized_keys
else
    echo "ERROR: No authorized keys found in $HOME/.ssh"
    exit 1
fi
docker exec -it ${container_name} bash -c "chown ${myuname}:${myuname} /home/${myuname}/.ssh/authorized_keys"

echo "Creating .docker_profile with appropriate environment variables"
# Set environment variables
docker exec -u "${myuname}" -it ${container_name} bash -c \
	"printf \"%s\n\" \
	'export VESPA_HOME=\$HOME/vespa' \
	'PATH=\$PATH:\$HOME/bin:\$VESPA_HOME/bin:\$HOME/git/system-test/bin:/opt/vespa-deps/bin' \
	'export PATH' \
	'export JAVA_HOME='\`echo /usr/lib/jvm/java-17-openjdk-*\` \
	'export MAVEN_OPTS=\"-Xms128m -Xmx1024m\"' \
	> ~/.docker_profile; cat ~/.docker_profile"

docker exec -u "${myuname}" -it ${container_name} bash -c \
        "grep -q '.docker_profile' ~/.bash_profile || echo 'test -f ~/.docker_profile && source ~/.docker_profile || true' >> ~/.bash_profile"

# Ensure home directory has correct owner and group (again)
docker exec -it ${container_name} bash -c "chown -R ${myuname}:${myuname} /home/${myuname}"

# Adjust ccache max size
docker exec -u "${myuname}" -it ${container_name} bash -c "ccache -M 20G"

if grep -q "Host $container_name" ~/.ssh/config; then
    echo "Host $container_name already exists in ~/.ssh/config - not adding it again"
else
    echo "Adding Host $container_name in your ~/.ssh/config redirecting via 127.0.0.1"
    (
	echo ""
	echo "Host $container_name"
	echo "        Hostname 127.0.0.1"
        echo "        Port 39${MAJOR_V}"
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
echo "Logging in on new docker container $container_name ..."
ssh $container_name
