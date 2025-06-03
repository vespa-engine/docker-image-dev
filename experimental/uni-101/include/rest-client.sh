set -euxo pipefail

echo "Installing REST Client plugin..."
sudo -u ${TARGET_USER} /usr/bin/code-server --install-extension humao.rest-client
