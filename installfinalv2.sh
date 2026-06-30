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
#sudo apt-get update
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

# ---------------------------------------------
# STEP 3: Install VIM , GVIM, YOSYS, GTKWAVE
# ---------------------------------------------
sudo apt-get install -y vim vim-gtk3 yosys gtkwave irsim

# -------------------------------
# STEP 4: Verilator 5.038
# -------------------------------
cd /labroot
git clone https://github.com/verilator/verilator.git
cd verilator
git checkout v5.038

autoconf
./configure || { echo "Configure failed"; exit 1; }
make -j$JOBS
sudo make install 

# -------------------------------
# STEP 5: GTKWave 3.3.103
# -------------------------------
#cd /labroot
#wget http://gtkwave.sourceforge.net/gtkwave-3.3.103.tar.gz
#tar -xzf gtkwave-3.3.103.tar.gz
#cd gtkwave-3.3.103

#./configure || { echo "Configure failed"; exit 1; }
#make -j$(nproc)
#sudo make install

# -------------------------------
# STEP 6: Yosys 0.9
# -------------------------------
#cd /labroot
#git clone https://github.com/YosysHQ/yosys.git
#cd yosys
#git checkout yosys-0.9
#make config-gcc || { echo "Configure failed"; exit 1; }
#make -j$(nproc)
#sudo make install

# -------------------------------
# STEP 7: RISC-V GCC
# -------------------------------
sudo apt-get install -y gcc-riscv64-unknown-elf

# -------------------------------
# STEP 2: Fix CMake
# -------------------------------
#pip3 uninstall cmake -y || true
#pip3 install cmake==3.26.4

sudo apt-get install -y pipx
pipx ensurepath
export PATH=$HOME/.local/bin:$PATH

pipx install cmake==3.26.4


# -------------------------------
# STEP 8: Abseil
# -------------------------------
cd /labroot
git clone https://github.com/abseil/abseil-cpp.git
cd abseil-cpp
git checkout 20240116.2

mkdir build && cd build
cmake .. -DCMAKE_CXX_STANDARD=17 || { echo "Configure failed"; exit 1; }
make -j$JOBS
sudo make install

# -------------------------------
# STEP 9: YAML-CPP
# -------------------------------
cd /labroot
git clone https://github.com/jbeder/yaml-cpp.git
cd yaml-cpp

mkdir build && cd build
cmake .. || { echo "Configure failed"; exit 1; }
make -j$(nproc)
sudo make install

# -------------------------------
# STEP 10: CUDD
# -------------------------------
cd /labroot
git clone https://github.com/ivmai/cudd.git
cd cudd

autoreconf -i
./configure || { echo "Configure failed"; exit 1; }
make -j$(nproc)
sudo make install

# -------------------------------
# STEP 11: GTest
# -------------------------------
cd /labroot
git clone https://github.com/google/googletest.git
cd googletest

mkdir build && cd build
cmake .. || { echo "Configure failed"; exit 1; }
make -j$(nproc)
sudo make install

# -------------------------------
# STEP 12: SWIG (Python)
# -------------------------------
sudo apt remove -y swig
sudo apt-get install -y \
  build-essential autoconf automake libtool \
  bison flex gawk \
  libpcre2-dev
cd /labroot
wget https://github.com/swig/swig/archive/refs/tags/v4.3.0.tar.gz
tar -xzf v4.3.0.tar.gz
cd swig-4.3.0
./autogen.sh
./configure
make -j$(nproc)
sudo make install
# -------------------------------
# STEP 13: Environment Variables
# -------------------------------
echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH' >> ~/.bashrc
echo 'export LIBRARY_PATH=/usr/local/lib:$LIBRARY_PATH' >> ~/.bashrc
echo 'export CMAKE_PREFIX_PATH="/usr/local;/usr/lib/x86_64-linux-gnu"' >> ~/.bashrc
echo 'export Qt5_DIR=/usr/lib/x86_64-linux-gnu/cmake/Qt5' >> ~/.bashrc
echo 'export LEMON_DIR=/usr/local/lib/cmake/lemon' >> ~/.bashrc


source ~/.bashrc

# -------------------------------
# STEP 14: OR-Tools
# -------------------------------
cd /labroot
git clone https://github.com/google/or-tools.git
cd or-tools
git checkout v9.8

mkdir build && cd build
cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=ON \
  -DBUILD_EXAMPLES=OFF \
  -DBUILD_TESTS=OFF \
  -DBUILD_DEPS=ON || { echo "Configure failed"; exit 1; }
#JOBS=$(nproc)
#[ "$JOBS" -gt 4 ] && JOBS=4   # stricter limit
make -j$JOBS
#make -j$(nproc)
sudo make install

# -------------------------------
# STEP 15: Boost 1.83
# -------------------------------
#cd /labroot
#wget https://archives.boost.io/release/1.83.0/source/boost_1_83_0.tar.gz
#tar -xzf boost_1_83_0.tar.gz
#cd boost_1_83_0

#./bootstrap.sh --prefix=/usr/local || { echo "Configure failed"; exit 1; }

#sudo ./b2 -j$(nproc) install

# -------------------------------
# STEP 15: Boost 1.87
# -------------------------------
cd /labroot
wget -O boost_1_87_0.tar.gz https://archives.boost.io/release/1.87.0/source/boost_1_87_0.tar.gz
tar -xvf boost_1_87_0.tar.gz
cd boost_1_87_0

./bootstrap.sh || { echo "Configure failed"; exit 1; }

sudo ./b2 -j$(nproc) install

# -------------------------------
# STEP 16: lemon
# -------------------------------
cd /labroot
wget https://github.com/The-OpenROAD-Project/lemon-graph/archive/refs/heads/master.tar.gz
tar -xzf master.tar.gz
cd lemon-graph-master
mkdir build && cd build
cmake .. \
  -DLEMON_ENABLE_ILOG=OFF \
  -DLEMON_ENABLE_GLPK=OFF \
  -DLEMON_ENABLE_COIN=OFF \
  -DLEMON_ENABLE_SOPLEX=OFF
make -j$(nproc)
sudo make install


pipx uninstall cmake
pipx install cmake==3.29.6
pipx ensurepath
export PATH=$HOME/.local/bin:$PATH

# -------------------------------
# Necessary Pre-requisites
# -------------------------------
sudo apt remove -y libfmt-dev libspdlog-dev
cd /labroot
git clone https://github.com/gabime/spdlog.git
cd spdlog
mkdir build && cd build
cmake .. -DSPDLOG_FMT_EXTERNAL=OFF
make -j$JOBS
sudo make install

# -------------------------------
# STEP 17: OpenROAD
# -------------------------------
cd /labroot
git clone https://github.com/The-OpenROAD-Project/OpenROAD.git
cd OpenROAD

git submodule update --init --recursive

sed -i 's/^#add_subdirectory(gpl)/add_subdirectory(gpl)/' src/CMakeLists.txt
sed -i 's/^#add_subdirectory(mpl)/add_subdirectory(mpl)/' src/CMakeLists.txt
sed -i 's/^#add_subdirectory(par)/add_subdirectory(par)/' src/CMakeLists.txt

mkdir build && cd build

cmake .. -DCMAKE_BUILD_TYPE=Release \
-DCMAKE_CXX_STANDARD=20 \
-DENABLE_TESTS=OFF \
-DSPDLOG_FMT_EXTERNAL=OFF \
-DFMT_EXTERNAL=OFF \
-DCMAKE_DISABLE_FIND_PACKAGE_ortools=OFF || { echo "Configure failed"; exit 1; }
make -j$JOBS 2>&1 | tee build.log
sudo make install


cd /labroot
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

print_tool_info "Vim" "vim"
print_tool_info "GVim" "gvim"
print_tool_info "Verilator" "verilator"
print_tool_info "GTKWave" "gtkwave"
print_tool_info "Yosys" "yosys"
print_tool_info "OpenROAD" "openroad"
print_tool_info "Klayout" "klayout"
print_tool_info "OpenSTA" "sta"
print_tool_info "RISC-V Tool Chain" "riscv64-unknown-elf-gcc"
echo "===== SETUP COMPLETE ====="
echo "#=============================================#"
echo "# Author       : Mukul Kumar                  #"
echo "# Designation  : Junior VLSI Engineer         #"         
echo "# Organization : NIELIT CoE Noida             #"
echo "#=============================================#"
