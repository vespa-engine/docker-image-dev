#!/bin/bash
# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

if [ $# -lt 2 ]; then
  echo "Usage: $0 <container-engine> <container-name>"
  exit 1
fi

engine=$1
container_name=$2

# Add yourself as user
$engine exec -it $container_name bash -c "groupadd -g $(id -g) $(id -gn)"
$engine exec -it $container_name bash -c "useradd -g $(id -g) -u $(id -u) $(id -un)"
$engine exec -it $container_name bash -c "echo '$(id -un) ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers"

# Ensure home directory has correct owner and group
$engine exec -it $container_name bash -c "chown $(id -u):$(id -g) /home/$(id -un)"

# Ensure home directory has correct permissions
$engine exec -it $container_name bash -c "chmod 755 /home/$(id -un)"

# Copy authorized keys
$engine exec -u "$(id -u):$(id -g)" -it $container_name bash -c "mkdir -p /home/$(id -un)/.ssh"

if test -f $HOME/.ssh/authorized_keys; then
  $engine cp -a $HOME/.ssh/authorized_keys $container_name:/home/$(id -un)/.ssh/
elif test -f $HOME/.ssh/id_rsa.pub; then
  $engine cp -a $HOME/.ssh/id_rsa.pub $container_name:/home/$(id -un)/.ssh/authorized_keys
elif test -f $HOME/.ssh/id_ed25519.pub; then
  $engine cp -a $HOME/.ssh/id_ed25519.pub $container_name:/home/$(id -un)/.ssh/authorized_keys
else
  echo "ERROR: No authorized keys found in $HOME/.ssh"
  exit 1
fi
$engine exec -it ${container_name} bash -c "chown $(id -un) /home/$(id -un)/.ssh/authorized_keys"

# Set environment variables
$engine exec -u "$(id -u):$(id -g)" -it $container_name bash -c \
"printf \"%s\n\" \
'export LC_CTYPE=en_US.UTF-8' \
'export LC_ALL=en_US.UTF-8' \
'export VESPA_HOME=\$HOME/vespa' \
'PATH=\$PATH:\$HOME/bin:\$VESPA_HOME/bin:\$HOME/git/system-test/bin:/opt/vespa-deps/bin' \
'export PATH' \
'export MAVEN_OPTS=\"-Xms128m -Xmx1024m\"' \
'alias ctest=ctest3' \
> ~/.docker_profile"
$engine exec -u "$(id -u):$(id -g)" -it $container_name bash -c \
"grep -q '.docker_profile' ~/.bash_profile || echo 'test -f ~/.docker_profile && source ~/.docker_profile || true' >> ~/.bash_profile"

# Adjust ccache max size
$engine exec -u "$(id -u):$(id -g)" -it $container_name bash -c "ccache -M 20G"
