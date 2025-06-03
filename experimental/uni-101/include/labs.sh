set -euxo pipefail

echo "Copying lab files for this training..."
git clone --depth 1 https://github.com/vespaai/university
mkdir -p "${USER_HOME}/lab"
mv university/101/* "${USER_HOME}/lab/."
rm -rf university

cp "${USER_HOME}/lab/check-setup.sh" /usr/local/bin/check-setup

echo "Making sure all files in the ${TARGET_USER} home directory belong to the ${TARGET_USER} user..."
chown -R "${TARGET_USER}:${TARGET_USER}" ${USER_HOME}
