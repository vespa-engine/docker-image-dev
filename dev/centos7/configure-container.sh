#!/bin/bash
# Copyright Verizon Media. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

if [ $# -lt 1 ]; then
  echo "Usage: $0 <container-name>"
  exit 1
fi

container_name=$1

# Add yourself as user
docker exec -it $container_name bash -c "groupadd -g $(id -g) $(id -gn)"
docker exec -it $container_name bash -c "useradd -g $(id -g) -u $(id -u) $(id -un)"
docker exec -it $container_name bash -c "echo '$(id -un) ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers"

# Ensure home directory has correct owner and group
docker exec -it $container_name bash -c "chown $(id -u):$(id -g) /home/$(id -un)"

# Copy authorized keys
docker exec -u "$(id -u):$(id -g)" -it $container_name bash -c "mkdir -p /home/$(id -un)/.ssh"

if test -f $HOME/.ssh/authorized_keys; then
  docker cp -a $HOME/.ssh/authorized_keys $container_name:/home/$(id -un)/.ssh/
elif test -f $HOME/.ssh/id_rsa.pub; then
  docker cp -a $HOME/.ssh/id_rsa.pub $container_name:/home/$(id -un)/.ssh/authorized_keys
else
  echo "No authorized keys found in $HOME/.ssh"
  exit 1
fi

# Set environment variables
docker exec -u "$(id -u):$(id -g)" -it $container_name bash -c \
"printf \"%s\n\" \
'export LC_CTYPE=en_US.UTF-8' \
'export LC_ALL=en_US.UTF-8' \
'export VESPA_HOME=\$HOME/vespa' \
'PATH=\$PATH:\$HOME/bin:\$VESPA_HOME/bin:\$HOME/git/system-test/bin:/opt/vespa-deps/bin' \
'export PATH' \
'export MAVEN_OPTS=\"-Xms128m -Xmx1024m\"' \
'alias ctest=ctest3' \
> ~/.docker_profile"
docker exec -u "$(id -u):$(id -g)" -it $container_name bash -c \
"grep -q '.docker_profile' ~/.bash_profile || echo 'test -f ~/.docker_profile && source ~/.docker_profile || true' >> ~/.bash_profile"

# Adjust ccache max size
docker exec -u "$(id -u):$(id -g)" -it $container_name bash -c "ccache -M 20G"
