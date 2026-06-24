# EDA-Tools-Installer

Automated installation scripts for Open-Source VLSI and EDA tools on Ubuntu, WSL2, and VirtualBox environments.

This repository provides ready-to-use shell scripts to install and configure a complete Open-Source ASIC Design Flow including RTL design, simulation, physical design, analog design, verification, and SKY130 PDK support.

---

# Supported Platforms

* Ubuntu 24 Native
* Ubuntu 24 on VirtualBox
* WSL2 (Windows Subsystem for Linux)
* Multi-user Linux Lab Systems

---

# Supported Tools

## Digital Design & Verification

* Yosys
* Verilator
* GTKWave
* Icarus Verilog
* OpenSTA
* OpenTimer

## Physical Design

* OpenROAD
* OpenLane

## Analog Design

* Magic VLSI
* Xschem
* Ngspice
* Netgen

## PDK Support

* SKY130 OpenPDKs

---

# Features

* Automated dependency installation
* WSL2-compatible setup
* Docker-based OpenLane environment
* SKY130-enabled launchers for Magic and Xschem
* Parallel compilation support
* Automatic tool verification after installation
* Beginner-friendly installation flow
* Compatible with Ubuntu, VirtualBox, and WSL2

---

# Repository Structure

```text
EDA-Tools-Installer/
│
├── installfinalv2.sh      # RTL-to-GDSII Digital Flow Tools
├── openlaneinstall.sh     # OpenLane + Docker Setup
├── pdk.sh                 # Analog Design + SKY130 PDK Setup
└── README.md
```

---

# Installation Guide

## Step 1: Update System

Before starting, update your Ubuntu/WSL system:

```bash
sudo apt update && sudo apt upgrade -y
```

Install dos2unix utility and git:

```bash
sudo apt-get install -y dos2unix git
```

---

## Step 2: Clone the Repository

Clone the repository to your system:

```bash
git clone https://github.com/mukulkumar011/EDA-Tools-Installer.git
```

---

## Step 3: Move into Repository Directory

```bash
cd EDA-Tools-Installer
```

---

## Step 4: Make Scripts Executable

Give executable permissions to all shell scripts:

```bash
sudo chmod +x *.sh
```

Convert Windows line endings if required:

```bash
sudo dos2unix *.sh
```

---

# Installation Scripts

## 1. Install OpenLane Environment

```bash
./openlaneinstall.sh
```

### This installs:

* Docker
* OpenLane
* SKY130 PDK Support
* OpenLane Launcher Command

---

## 2. Install Analog Design Environment

```bash
./pdk.sh
```

### This installs:

* Ngspice
* Xschem
* Magic VLSI
* Netgen
* OpenPDKs (SKY130)
* OpenTimer

---

## 3. Install Digital RTL-to-GDSII Flow Tools

```bash
./installfinalv2.sh
```

### This installs:

* Yosys
* Verilator
* GTKWave
* OpenROAD
* OpenSTA
* KLayout
* RISC-V Toolchain
* Icarus Verilog

---

## 4. Install Digital RTL-to-GDSII Flow Toolchain (Qflow)

```bash
./qflow.sh
```

### This installs:

* Graywolf
* Qrouter
* Qflow

---


# Restart Terminal Session

Some tools require environment variables and group permissions to refresh.

Recommended:

```bash
logout
```

or restart your terminal/WSL session after installation.

---

# Verify Installation

Check whether tools are installed correctly:

```bash
yosys -V
```

```bash
verilator --version
```

```bash
magic
```

```bash
xschem
```

```bash
openroad
```

```bash
openlane
```

---

# Notes for WSL2 Users

## WSLg Support

Windows 11 users already have WSLg support enabled by default.

For Windows 10 users:

* Install an X Server such as:

  * VcXsrv
  * Xming

---

## DISPLAY Variable

If GUI applications are not opening:

```bash
export DISPLAY=:0
```

---

# Recommended System Requirements

| Component | Recommended       |
| --------- | ----------------- |
| RAM       | 16 GB or Higher   |
| CPU       | 4 Cores or Higher |
| Storage   | 150 GB Free Space |
| OS        | Ubuntu 24         |
| WSL       | WSL2              |

---

# Troubleshooting

## Docker Permission Error

If Docker shows permission denied:

```bash
sudo usermod -aG docker $USER
```

Then logout and login again.

---

## OpenGL / GUI Issues in WSL

Install required packages:

```bash
sudo apt install mesa-utils x11-apps -y
```

---

## Verify Docker Installation

```bash
docker run hello-world
```

---

# Developed By

Mukul Kumar

Junior VLSI Engineer

NIELIT CoE Noida

---

# Disclaimer

These scripts are provided "as is" without any warranties or guarantees of any kind, either express or implied.

The author shall not be held responsible or liable for any damage, data loss, system instability, security issues, configuration problems, or other consequences resulting from the use or misuse of these scripts.

Users are advised to review the scripts carefully and use them at their own risk. It is recommended to test the installation in a controlled or backup environment before deploying on production systems.

These scripts are intended solely for educational, research, and development purposes related to Open-Source VLSI and ASIC Design workflows.
