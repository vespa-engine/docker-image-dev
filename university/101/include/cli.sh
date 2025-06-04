set -euxo pipefail

echo "Installing Vespa CLI..."

# get the latest version of Vespa CLI
VESPA_VERSION=$(curl -s https://api.github.com/repos/vespa-engine/vespa/releases | jq -r '.[].name' | grep Vespa.CLI | head -n 1 | sed 's|.*\ ||')
PATH_TO_ADD="/opt/vespa/vespa-cli_${VESPA_VERSION}_linux_amd64/bin"

curl -fsSL -o vespa-cli.tar.gz https://github.com/vespa-engine/vespa/releases/download/v${VESPA_VERSION}/vespa-cli_${VESPA_VERSION}_linux_amd64.tar.gz
mkdir -p /opt/vespa
tar -xzf vespa-cli.tar.gz -C /opt/vespa

cp $PATH_TO_ADD/vespa /usr/local/bin/.

# Ensure .bashrc exists for the user
if [ ! -f "${USER_HOME}/.bashrc" ]; then
  echo "Creating .bashrc for user ${TARGET_USER}."
  touch "${USER_HOME}/.bashrc"
fi

# Add the path to .bashrc if it's not already there
if ! grep -q "PATH=.*$PATH_TO_ADD" "${USER_HOME}/.bashrc"; then
  echo "Adding $PATH_TO_ADD to .bashrc for user ${TARGET_USER}."
  echo "export PATH=\$PATH:$PATH_TO_ADD" >> "${USER_HOME}/.bashrc"
else
  echo "$PATH_TO_ADD is already in .bashrc for user ${TARGET_USER}."
fi
