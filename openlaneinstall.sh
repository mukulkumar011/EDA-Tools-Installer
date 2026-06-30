#!/bin/bash

echo "#============================================================#"
echo "# OpenLane Complete Installation Script                      #"
echo "# Author         : Mukul Kumar                               #"
echo "# Designation    : Junior VLSI Engineer                      #"
echo "# Organization   : NIELIT CoE Noida                          #"
echo "# Purpose        : Install Docker, OpenLane and Create Alias #"
echo "# Compatible With:                                           #"
echo "#   - Ubuntu Native                                          #"
echo "#   - Ubuntu on VirtualBox                                   #"
echo "#   - WSL2                                                   #"
echo "#   - Multi-user Linux Labs                                  #"
echo "#============================================================#"

set -euo pipefail

echo "=================================================="
echo " Updating System Packages"
echo "=================================================="

#sudo apt update -y
sudo apt-get upgrade -y

echo "=================================================="
echo " Installing Required Dependencies"
echo "=================================================="

sudo apt-get install -y \
    ca-certificates \
    curl \
    build-essential \
    python3 \
    python3-venv \
    python3-pip \
    python3-tk \
    make \
    git \
    x11-xserver-utils \
    xauth

	
#sudo apt update
sudo apt install -y \
	mesa-utils \
	libgl1 \
	libglx-mesa0 \
	libgl1-mesa-dri \
	x11-apps
echo "=================================================="
echo " Installing Docker"
echo "=================================================="

# Create Docker keyring directory
sudo install -m 0755 -d /etc/apt/keyrings

# Add Docker GPG key
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc

sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) \
  signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package list
#sudo apt-get update -y

# Install Docker packages
sudo apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io

echo "=================================================="
echo " Starting Docker Service"
echo "=================================================="

# Start Docker depending on init system
if command -v systemctl >/dev/null 2>&1; then
    sudo systemctl start docker
    sudo systemctl enable docker
else
    sudo service docker start
fi

echo "=================================================="
echo " Verifying Docker Installation"
echo "=================================================="

sudo docker run hello-world

echo "=================================================="
echo " Configuring Docker Permissions"
echo "=================================================="

# Create docker group if not already present
sudo groupadd docker || true

# Add current user to docker group
sudo usermod -aG docker $USER

echo "=================================================="
echo " Checking /labroot Directory"
echo "=================================================="

if [ ! -d "/labroot" ]; then
    echo "/labroot directory not found."
    echo "Creating /labroot ..."

    sudo mkdir -p /labroot

    # Give ownership to current user
    sudo chown -R $USER:$USER /labroot

    echo "/labroot created successfully."
else
    echo "/labroot already exists."
fi

echo "=================================================="
echo " Cloning OpenLane Repository"
echo "=================================================="

cd /labroot

if [ ! -d "OpenLane" ]; then
    git clone https://github.com/The-OpenROAD-Project/OpenLane
else
    echo "OpenLane repository already exists."
fi

sudo chown -R $USER:$USER /labroot/OpenLane
sudo chown -R $USER:$USER $HOME/.ciel 2>/dev/null || true
git config --global --add safe.directory /labroot/OpenLane

echo "=================================================="
echo " Downloading OpenLane CI Designs"
echo "=================================================="

cd /labroot

if [ ! -d "openlane-ci-designs" ]; then
    git clone https://github.com/efabless/openlane-ci-designs.git
else
    echo "openlane-ci-designs repository already exists."
fi

echo "=================================================="
echo " Copying CI Designs to OpenLane/designs"
echo "=================================================="

sudo cp -r /labroot/openlane-ci-designs/* /labroot/OpenLane/designs/ 2>/dev/null || true
sudo rm -rf /labroot/openlane-ci-designs/

echo "CI designs copied successfully."

echo "=================================================="
echo " Cleaning Previous Virtual Environment"
echo "=================================================="

sudo rm -rf /labroot/OpenLane/venv

echo "=================================================="
echo " Refreshing Docker Group"
echo "=================================================="

# Refresh docker group for current script session
newgrp docker <<EONG

echo "=================================================="
echo " Verifying Docker Access"
echo "=================================================="

docker run hello-world

echo "=================================================="
echo " Building OpenLane"
echo "=================================================="

cd /labroot/OpenLane

make

echo "=================================================="
echo " Running OpenLane Test"
echo "=================================================="

make test

EONG



echo "=================================================="
echo " Creating OpenLane Alias Command"
echo "=================================================="

sudo bash -c 'cat > /usr/local/bin/openlane << "EOF"
#!/bin/bash

# =========================================================
# OpenLane Launcher
# =========================================================

# Per-user OpenLane workspace
USER_OL_DIR="$HOME/OpenLaneUser"

mkdir -p "$USER_OL_DIR/designs"

# Copy example designs on first run
if [ ! -d "$USER_OL_DIR/designs/spm" ]; then
    echo "[INFO] Copying example designs to your workspace..."
    cp -r /labroot/OpenLane/designs/* "$USER_OL_DIR/designs/" 2>/dev/null || true
fi

echo "========================================"
echo " OpenLane started for user: $USER"
echo " Workspace : $USER_OL_DIR"
echo "========================================"

# Allow Docker GUI access for VirtualBox/Linux
xhost +local:docker >/dev/null 2>&1 || true

docker run --rm -v /labroot/OpenLane:/openlane -v /labroot/OpenLane/designs:/openlane/install -v $HOME:$HOME -v $HOME/.ciel:$HOME/.ciel -e PDK_ROOT=$HOME/.ciel -e PDK=sky130A --user $(id -u):$(id -g) -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --network host --security-opt seccomp=unconfined -ti ghcr.io/the-openroad-project/openlane:ff5509f65b17bfa4068d5336495ab1718987ff69-amd64
EOF'

# Make launcher executable
sudo chmod +x /usr/local/bin/openlane

echo "=================================================="
echo " OpenLane command created successfully"
echo "=================================================="

echo ""
echo "=================================================="
echo " OpenLane Installation Completed Successfully"
echo "=================================================="

echo ""
echo "IMPORTANT:"
echo "Please logout and login again"
echo ""
echo "Then launch OpenLane using:"
echo ""
echo "openlane"
echo ""
echo "===== SETUP COMPLETE ====="
echo "#=============================================#"
echo "# Author       : Mukul Kumar                  #"
echo "# Designation  : Junior VLSI Engineer         #"         
echo "# Organization : NIELIT CoE Noida             #"
echo "#=============================================#"
