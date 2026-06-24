#!/bin/bash

echo "#============================================================#"
echo "# Qflow Installation Script                                  #"
echo "# Author         : Mukul Kumar                               #"
echo "# Designation    : Junior VLSI Engineer                      #"
echo "# Organization   : NIELIT CoE Noida                          #"                
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

sudo apt-get update -y
sudo apt-get install -y \
    git build-essential cmake autoconf automake libtool \
    tcl tcl-dev tk tk-dev \
    tcsh csh \
    m4 flex bison \
    libx11-dev libxft-dev libxext-dev libcairo2-dev \
    libglu1-mesa-dev freeglut3-dev \
    python3 python3-pip \
    wget curl
	
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

# -------------------------------
# STEP 1: Graywolf
# -------------------------------

cd /labroot
rm -rf graywolf
git clone https://github.com/rubund/graywolf.git
cd graywolf
mkdir -p build && cd build
cmake ..
make -j$(nproc)
sudo make install

# -------------------------------
# STEP 2: Qrouter
# -------------------------------

cd /labroot
rm -rf qrouter
git clone https://github.com/RTimothyEdwards/qrouter.git
cd qrouter
./configure
make -j$(nproc)
sudo make install

# -------------------------------
# STEP 3: Qflow
# -------------------------------

cd /labroot
rm -rf qflow
git clone https://github.com/RTimothyEdwards/qflow.git
cd qflow
./configure
make -j$(nproc)
sudo make install

echo "===== INSTALLATION COMPLETE ====="
echo "===== FINAL TOOL STATUS ====="
print_tool_info() {
    local TOOL_NAME="$1"
    local CMD="$2"

    echo "$TOOL_NAME"

    if command -v "$CMD" >/dev/null 2>&1; then
        echo "Location: $(command -v "$CMD")"

        VERSION=$(
            "$CMD" --version 2>/dev/null | head -n 1 || \
            "$CMD" -version 2>/dev/null | head -n 1 || \
            "$CMD" -v 2>/dev/null | head -n 1 || true
        )

        if [ -n "$VERSION" ]; then
            echo "   🔹 Version: $VERSION"
        else
            echo "   🔹 Version: Version info unavailable"
        fi
    else
        echo "   ❌ Not Found"
    fi

    echo ""
}
print_tool_info "Graywolf" "graywolf"
print_tool_info "Qrouter" "qrouter"
print_tool_info "Qflow" "qflow"
echo "===== SETUP COMPLETE ====="
echo "#=============================================#"
echo "# Author       : Mukul Kumar                  #"
echo "# Designation  : Junior VLSI Engineer         #"         
echo "# Organization : NIELIT CoE Noida             #"
echo "#=============================================#"
