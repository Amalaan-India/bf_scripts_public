#!/bin/bash

echo "Starting linux_setup.sh, LSH"

flog="LSH:" # Filename in log
logF() {
    msg=$1
    echo "$flog $msg"
}

logF "Run with \$(bash linux_setup.sh) NOT sudo sh..."
USER=$(whoami)
arch=$(uname -m)

# Step 1: Create root user "bugflows" with password "bugflows"
logF "Creating root user 'bugflows'"
if ! id "bugflows" &>/dev/null; then
    sudo useradd -m -s /bin/bash bugflows
    echo "bugflows:bugflows" | sudo chpasswd
    echo "bugflows ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/bugflows
    sudo chmod 0440 /etc/sudoers.d/bugflows
else
    logF "User 'bugflows' already exists"
fi

# Step 2: Switch to the new user and re-execute this script
if [ "$USER" != "bugflows" ]; then
    logF "Switching to user 'bugflows' and re-running the script"
    sudo -u bugflows bash "$0"
    exit 0
fi

logF "Running as $(whoami)"
logF "Updating and Upgrading"
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get full-upgrade -y
sudo apt-get clean

logF "Installing Packages"
sudo apt-get install -y docker.io nano dirmngr gnupg software-properties-common curl gcc build-essential p7zip-full nano git \
    python3 python3-venv \
    llvm cifs-utils \
    pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev apt-transport-https ca-certificates

logF "Installing docker compose v2"
sudo groupadd docker 2>/dev/null
sudo usermod -aG docker $USER
DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.30.3/docker-compose-linux-$arch -o $DOCKER_CONFIG/cli-plugins/docker-compose
chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose
sudo systemctl restart docker

logF "Enabling passwordless sudo for current user"
echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$USER
sudo chmod 0440 /etc/sudoers.d/$USER

logF "Updating and Upgrading (again)"
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get full-upgrade -y
sudo apt-get clean

logF "Current IP"
ip addr

logF "Setup complete, rebooting..."
sudo shutdown -r now "Restarting to finish updates, upgrades and setup (Docker specifically)"
