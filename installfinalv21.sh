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

sudo chown -R "$USER:$USER" /labroot
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
sudo apt-get install -y vim vim-gtk3 iverilog klayout
echo "===== Checking Required Tools ====="

echo "===== Checking System Dependencies ====="

# -------------------------------
# COMMAND CHECKS
# -------------------------------
commands=(gcc g++ make flex bison perl python3 git cmake pkg-config gawk wget curl)

for tool in "${commands[@]}"; do
  if command -v "$tool" &> /dev/null; then
    echo "✅ Found command: $tool → $(which "$tool")"
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

# -------------------------------
# STEP 17: OpenROAD and OpenSTA
# -------------------------------
OPENROAD_DIR="/labroot/OpenROAD"
OPENSTA_DIR="/labroot/OpenSTA"
OPENROAD_DEPS="/labroot/openroad-deps"

# Do not create /labroot/OpenROAD before cloning: Git requires the destination
# to be absent (or an existing Git checkout).
if [ ! -d "$OPENROAD_DIR/.git" ]; then
  git clone --recurse-submodules https://github.com/The-OpenROAD-Project/OpenROAD.git "$OPENROAD_DIR"
else
  echo "Reusing existing OpenROAD checkout: $OPENROAD_DIR"
  git -C "$OPENROAD_DIR" submodule update --init --recursive
fi

cd "$OPENROAD_DIR"

# OpenROAD's CMake build is deprecated and the current source tree can fail
# during CMake configuration with a missing build_and_test target.  Install
# Bazel dependencies for OpenROAD's supported build path.
sudo ./etc/DependencyInstaller.sh -bazel

# Keep the original CMake dependency prefix for the separately-built OpenSTA.
sudo ./etc/DependencyInstaller.sh -cmake -base
sudo ./etc/DependencyInstaller.sh -cmake -common -prefix="$OPENROAD_DEPS" -threads="$JOBS"

export PATH="$OPENROAD_DEPS/bin:$PATH"

# Build and install native OpenROAD with Bazel.  It installs openroad in the
# default system location, /usr/local/bin/openroad.
sudo ./etc/Build.sh -prefix=/usr/local -threads="$JOBS"

# OpenSTA is installed separately so the standalone `sta` command is available.
if [ ! -d "$OPENSTA_DIR/.git" ]; then
  git clone --depth 1 https://github.com/parallaxsw/OpenSTA.git "$OPENSTA_DIR"
else
  echo "Reusing existing OpenSTA checkout: $OPENSTA_DIR"
fi

"$OPENROAD_DEPS/bin/cmake" -S "$OPENSTA_DIR" -B "$OPENSTA_DIR/build" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCUDD_DIR="$OPENROAD_DEPS" \
  -DCMAKE_PREFIX_PATH="$OPENROAD_DEPS"
"$OPENROAD_DEPS/bin/cmake" --build "$OPENSTA_DIR/build" --parallel "$JOBS"
sudo "$OPENROAD_DEPS/bin/cmake" --install "$OPENSTA_DIR/build"

# Both native tools use libraries from the shared dependency prefix.
printf '%s\n' "$OPENROAD_DEPS/lib" "$OPENROAD_DEPS/or-tools/lib" | \
  sudo tee /etc/ld.so.conf.d/openroad-deps.conf >/dev/null
sudo ldconfig

cd ~

# These packages are not required for OpenROAD/OpenSTA.  Install them only
# when the configured Ubuntu repository provides them, so an absent optional
# package cannot make an otherwise successful tool installation fail.
optional_pkgs=()
for pkg in libnglib-dev netgen-headers; do
  if apt-cache show "$pkg" >/dev/null 2>&1; then
    optional_pkgs+=("$pkg")
  else
    echo "Optional package not available on this Ubuntu release: $pkg"
  fi
done
if [ ${#optional_pkgs[@]} -gt 0 ]; then
  sudo apt-get install -y "${optional_pkgs[@]}"
fi

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
