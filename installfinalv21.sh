#!/bin/bash
set -euo pipefail

echo "#=============================================#"
echo "# Author       : Mukul Kumar                  #"
echo "# Designation  : Junior VLSI Engineer         #"         
echo "# Organization : NIELIT CoE Noida             #"
echo "#=============================================#"

if [ ! -d "/labroot" ]; then
    echo "Creating /labroot directory..."
    sudo mkdir -p /labroot
fi

if [ ! -d "/labroot/openroad" ]; then
    echo "Creating /labroot/openROAD directory..."
    sudo mkdir -p /labroot/openROAD
fi

sudo chown -R $USER:$USER /labroot
cd /labroot

# Detect cores
CORES=$(nproc)
# Safe cap (important)
if [ "$CORES" -ge 8 ]; then
  JOBS=4
else
  JOBS=2
fi
echo "Detected $CORES cores, using $JOBS parallel jobs"

# -------------------------------
# STEP 1: System Dependencies
# -------------------------------
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y \
vim vim-gtk3 iverilog klayout
echo "===== Checking Required Tools ====="

echo "===== Checking System Dependencies ====="

# -------------------------------
# COMMAND CHECKS
# -------------------------------
commands=(gcc g++ make flex bison perl python3 git cmake pkg-config gawk wget curl)

for tool in "${commands[@]}"; do
  if command -v $tool &> /dev/null; then
    echo "✅ Found command: $tool → $(which $tool)"
  else
    echo "❌ Missing command: $tool"
  fi
done

# -------------------------------
# PACKAGE CHECKS
# -------------------------------
packages=(
  build-essential clang
  help2man gperf
  libfl-dev libreadline-dev libncurses5-dev
  tcl tcl-dev tk tk-dev tcllib
  libffi-dev zlib1g-dev
  libboost-all-dev
  libx11-dev libxaw7-dev libxft-dev libxrender-dev libxext-dev
  libglu1-mesa-dev freeglut3-dev
  libgtk-3-dev
  qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools
  libqt5svg5-dev libqt5charts5-dev
  automake autoconf libtool
  libspdlog-dev libfmt-dev
  graphviz xdot
  python3-pip python3-dev python3-tk
  gsl-bin libgsl-dev
)

for pkg in "${packages[@]}"; do
  if dpkg -s "$pkg" &> /dev/null; then
    echo "✅ Installed package: $pkg"
  else
    echo "❌ Missing package: $pkg"
  fi
done

missing_pkgs=()

for pkg in "${packages[@]}"; do
  if ! dpkg -s "$pkg" &> /dev/null; then
    missing_pkgs+=("$pkg")
  fi
done

if [ ${#missing_pkgs[@]} -ne 0 ]; then
  echo "Installing missing packages: ${missing_pkgs[*]}"
  sudo apt-get install -y "${missing_pkgs[@]}"
else
  echo "✅ All system packages already installed"
fi

sudo apt-get install -y \
  build-essential \
  git clang \
  bison flex gawk m4 \
  help2man gperf \
  perl \
  pkg-config \
  libfl-dev libreadline-dev \
  libncurses5-dev \
  tcl tcl-dev tk tk-dev tcllib tclsh tcsh \
  libffi-dev zlib1g-dev \
  libboost-all-dev \
  libx11-dev libxaw7-dev libxft-dev libxrender-dev libxext-dev \
  libglu1-mesa-dev freeglut3-dev \
  libgtk-3-dev \
  qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools \
  libqt5svg5-dev libqt5charts5-dev \
  automake autoconf libtool \
  libspdlog-dev libfmt-dev \
  graphviz xdot \
  python3 python3-pip python3-dev python3-tk pipx \
  gsl-bin libgsl-dev \
  wget curl ca-certificates
sudo apt-get install -y \
  build-essential git clang bison flex libfl-dev libreadline-dev \
  tcl-dev libffi-dev zlib1g-dev libboost-all-dev \
  qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools libqt5svg5-dev \
  libqt5charts5-dev \
  automake autoconf libtool m4 libspdlog-dev libfmt-dev \
  pkg-config gawk wget curl ca-certificates \
  tcl tk tcllib tclsh tcsh \
  libx11-dev libxaw7-dev libglu1-mesa-dev freeglut3-dev \
  graphviz xdot \
  python3 python3-pip python3-tk \
  gsl-bin libgsl-dev \

# -------------------------------
# STEP 17: OpenROAD
# -------------------------------
cd /labroot/openROAD
#git clone https://github.com/The-OpenROAD-Project/OpenROAD.git
git clone --recurse-submodules https://github.com/The-OpenROAD-Project/OpenROAD.git /labroot/OpenROAD
cd OpenROAD && cd etc
sudo ./DependencyInstaller.sh -base
sudo ./DependencyInstaller.sh -cmake -base
sudo ./DependencyInstaller.sh -cmake -common -prefix=/labroot/openroad-deps -threads=2
cd /labroot/OpenROAD/etc
PATH=/labroot/openroad-deps/bin:$PATH ./Build.sh -cmake-build -cmake="-DCMAKE_PREFIX_PATH=/labroot/openroad-deps"
sudo /labroot/openroad-deps/bin/cmake --install /labroot/openroad/build
cd ~

sudo apt-get install -y \
libnglib-dev netgen-headers


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


print_tool_info "OpenROAD" "openroad"
print_tool_info "OpenSTA" "sta"
print_tool_info "RISC-V Tool Chain" "riscv64-unknown-elf-gcc"
echo "===== SETUP COMPLETE ====="
echo "#=============================================#"
echo "# Author       : Mukul Kumar                  #"
echo "# Designation  : Junior VLSI Engineer         #"         
echo "# Organization : NIELIT CoE Noida             #"
echo "#=============================================#"

