#!/bin/bash

echo "#============================================================#"
echo "# Open PDK Installation Script                               #"
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

#sudo apt update
sudo apt upgrade -y
sudo apt install -y build-essential git autoconf automake libtool \
                    tcl-dev tk-dev libcairo2-dev m4 flex bison \
                    libx11-dev libxpm-dev libxaw7-dev libreadline-dev \
                    libncurses-dev libglu1-mesa-dev freeglut3-dev mesa-common-dev \
                    pkg-config python3 python3-tk xterm
					
#sudo apt update

sudo apt install -y \
build-essential \
git \
m4 \
tcsh \
csh \
libx11-dev \
tcl-dev \
tk-dev \
libcairo2-dev \
mesa-common-dev \
libglu1-mesa-dev \
freeglut3-dev \
python3 \
bison \
flex \
libxrender-dev \
libxpm-dev \
libxext-dev					
					
sudo apt-get install -y netgen
echo "=================================================="
echo " Checking /labroot Directory"
echo "=================================================="

if [ ! -d "/labroot/pdk" ]; then
    echo "/labroot directory not found."
    echo "Creating /labroot/pdk ..."

    sudo mkdir -p /labroot/pdk

    # Give ownership to current user
    sudo chown -R $USER:$USER /labroot

    echo "/labroot/pdk created successfully."
else
    echo "/labroot/pdk already exists."
fi

# -------------------------------
# STEP 1: Ngspice
# -------------------------------

#cd /labroot/pdk
#git clone https://git.code.sf.net/p/ngspice/ngspice ngspice_git
#cd ngspice_git
#mkdir release
#./autogen.sh
#cd release
#../configure --with-x --enable-xspice --disable-debug --enable-cider --with-readline=yes --enable-openmp --enable-osdi
#make
#sudo make install

# -------------------------------
#  OpenTimer
# -------------------------------

#cd /labroot/pdk
#git clone https://github.com/OpenTimer/OpenTimer.git
#cd OpenTimer
#mkdir build
#cd build
#cmake ..
#make
#sudo make install

# -------------------------------
# STEP 2: Xschem
# -------------------------------

#cd /labroot/pdk
#git clone https://github.com/StefanSchippers/xschem.git xschem-src
#cd xschem-src
#./configure
#make
#sudo make install
#cd /labroot/pdk/xschem-src/xschem_library
#sudo git pull

# -------------------------------
# STEP 3: Magic
# -------------------------------

#cd /labroot/pdk
#git clone https://github.com/RTimothyEdwards/magic.git
#cd magic
#./configure
#make
#sudo make install
#hash -r

# -------------------------------
# STEP 4: OpenPDKs
# -------------------------------
cd /labroot/pdk
git clone git://opencircuitdesign.com/open_pdks
cd open_pdks
./configure --enable-sky130-pdk 
make
sudo make install


echo "===== INSTALLATION COMPLETE ====="
echo "===== SETUP COMPLETE ====="
echo "#=============================================#"
echo "# Author       : Mukul Kumar                  #"
echo "# Designation  : Junior VLSI Engineer         #"         
echo "# Organization : NIELIT CoE Noida             #"
echo "#=============================================#"
