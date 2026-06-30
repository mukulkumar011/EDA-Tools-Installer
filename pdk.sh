#!/bin/bash

echo "#============================================================#"
echo "# Analog Complete with Open PDK Installation Script          #"
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
# STEP 1: Ngspice
# -------------------------------

cd /labroot
git clone https://git.code.sf.net/p/ngspice/ngspice ngspice_git
cd ngspice_git
mkdir release
./autogen.sh
cd release
../configure --with-x --enable-xspice --disable-debug --enable-cider --with-readline=yes --enable-openmp --enable-osdi
make
sudo make install

# -------------------------------
#  OpenTimer
# -------------------------------

cd /labroot
git clone https://github.com/OpenTimer/OpenTimer.git
cd OpenTimer
mkdir build
cd build
cmake ..
make
sudo make install

# -------------------------------
# STEP 2: Xschem
# -------------------------------

cd /labroot
git clone https://github.com/StefanSchippers/xschem.git xschem-src
cd xschem-src
./configure
make
sudo make install
cd /labroot/xschem-src/xschem_library
sudo git pull

# -------------------------------
# STEP 3: Magic
# -------------------------------

cd /labroot
git clone https://github.com/RTimothyEdwards/magic.git
cd magic
./configure
make
sudo make install
hash -r

# -------------------------------
# STEP 4: OpenPDKs
# -------------------------------
cd /labroot
git clone git://opencircuitdesign.com/open_pdks
cd open_pdks
./configure --enable-sky130-pdk 
make
sudo make install

rm -f ~/xschemrc

echo "=========================================="
echo "Creating xschem launcher wrapper..."
echo "=========================================="

# Backup original xschem binary if not already backed up
if [ -f /usr/local/bin/xschem ] && [ ! -f /usr/local/bin/xschem_bin ]; then
    sudo mv /usr/local/bin/xschem /usr/local/bin/xschem_bin
fi

# Create launcher wrapper
sudo tee /usr/local/bin/xschem > /dev/null << 'EOF'
#!/bin/bash

echo "=================================="
echo "        XSCHEM LAUNCHER"
echo "=================================="
echo "1. Normal xschem"
echo "2. SKY130-enabled xschem"
echo ""

read -p "Select option [1-2]: " choice

case $choice in

    1)
        echo "Launching normal xschem..."

        TEMP_HOME="/tmp/xschem_clean_home"

        mkdir -p "$TEMP_HOME"

        HOME="$TEMP_HOME" xschem_bin
        ;;

    2)
        echo "Launching SKY130-enabled xschem..."

        PROJECT_DIR="$HOME/xschem_sky130_project"

        mkdir -p "$PROJECT_DIR"

        echo 'source /usr/local/share/pdk/sky130B/libs.tech/xschem/xschemrc' > "$PROJECT_DIR/xschemrc"

        cd "$PROJECT_DIR"

        xschem_bin
        ;;

    *)
        echo "Invalid option."
        exit 1
        ;;
esac
EOF

# Make wrapper executable
sudo chmod +x /usr/local/bin/xschem

echo "xschem launcher wrapper installed successfully."

echo "=========================================="
echo "Creating Magic launcher wrapper..."
echo "=========================================="

# Backup original magic binary if not already backed up
if [ -f /usr/local/bin/magic ] && [ ! -f /usr/local/bin/magic_bin ]; then
    sudo mv /usr/local/bin/magic /usr/local/bin/magic_bin
fi

# Create launcher wrapper
sudo tee /usr/local/bin/magic > /dev/null << 'EOF'
#!/bin/bash

echo "=================================="
echo "         MAGIC LAUNCHER"
echo "=================================="
echo "1. Normal Magic"
echo "2. SKY130-enabled Magic"
echo ""

read -p "Select option [1-2]: " choice

case $choice in

    1)
        echo "Launching normal Magic..."

        magic_bin
        ;;

    2)
        echo "Launching SKY130-enabled Magic..."

        PROJECT_DIR="$HOME/magic_sky130_project"

        mkdir -p "$PROJECT_DIR"

        cd "$PROJECT_DIR"

        magic_bin -rcfile /usr/local/share/pdk/sky130B/libs.tech/magic/sky130B.magicrc
        ;;

    *)
        echo "Invalid option."
        exit 1
        ;;
esac
EOF

# Make wrapper executable
sudo chmod +x /usr/local/bin/magic

echo "Magic launcher wrapper installed successfully."
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
print_tool_info "Magic" "magic_bin"
print_tool_info "Xschem" "xschem_bin"
print_tool_info "Netgen" "netgen"
print_tool_info "Ngspice" "ngspice"
echo "===== SETUP COMPLETE ====="
echo "#=============================================#"
echo "# Author       : Mukul Kumar                  #"
echo "# Designation  : Junior VLSI Engineer         #"         
echo "# Organization : NIELIT CoE Noida             #"
echo "#=============================================#"
