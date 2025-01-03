#!/bin/bash

echo "Starting setup of backend_ml, BML"

flog="BML:" #Filename in log
logF() {    #log file
    msg=$1
    echo "$flog $msg"
}

USER=$(whoami)
arch=$(uname -m)

logF "Updating and Upgrading"
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get full-upgrade -y
sudo apt-get clean

logF "Installing Packages"
sudo apt-get install -y docker.io nano dirmngr gnupg software-properties-common curl gcc build-essential p7zip-full nano git \
    python3 python3-venv python3-dev python3-pip python3.*-venv libblas-dev liblapack-dev \
    llvm cifs-utils \
    pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev apt-transport-https ca-certificates

logF "Installing docker compose v2"
sudo groupadd docker
sudo usermod -aG docker $USER
DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.30.3/docker-compose-linux-$arch -o $DOCKER_CONFIG/cli-plugins/docker-compose
chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose
sudo systemctl restart docker

logF "Installing Python packages"
pip install virtualenv

logF "Enabling passwordless sudo for current user"
echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$USER
sudo chmod 0440 /etc/sudoers.d/$USER

logF "Enabling password based SSH"
sed -i '/^PasswordAuthentication/d' /etc/ssh/sshd_config
echo "PasswordAuthentication yes" | sudo tee -a /etc/ssh/sshd_config

logF "Starting SSH and enabling autostart on boot"
sudo systemctl enable ssh
sudo systemctl start ssh

logF "Updating and Upgrading"
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get full-upgrade -y
sudo apt-get clean

logF "Current IP"
ip addr
