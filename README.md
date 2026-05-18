# EDA-Tools-Installer
Automated installation scripts for Open-Source VLSI and EDA tools on Ubuntu, WSL2, and VirtualBox environments. Includes OpenLane, OpenROAD, Yosys, Verilator, Magic, Xschem, Ngspice, SKY130/OpenPDKs, GTKWave, and more.

Installation Guide
Step 1: Update System

Before starting, update your Ubuntu/WSL system:

sudo apt update && sudo apt upgrade -y
Step 2: Clone the Repository

Clone the repository to your system:

git clone https://github.com/<your-username>/<repository-name>.git

Example:

git clone https://github.com/mukulkumar/OpenEDA-Lab.git
Step 3: Move into Repository Directory
cd <repository-name>

Example:

cd OpenEDA-Lab
Step 4: Make Scripts Executable

Give executable permissions to all shell scripts:

chmod +x *.sh

If scripts are inside folders:

chmod +x scripts/**/*.sh
Step 5: Run Installation Script
Install OpenLane Environment
./openlaneinstall.sh

This installs:

Docker
OpenLane
SKY130 PDK Support
OpenLane launcher command
Install Analog Design Environment
./pdk.sh

This installs:

Ngspice
Xschem
Magic VLSI
Netgen
OpenPDKs (SKY130)
Install Digital RTL-to-GDS Flow Tools
./installfinalv2.sh

This installs:

Yosys
Verilator
GTKWave
OpenROAD
OpenSTA
KLayout
RISC-V Toolchain
Step 6: Restart Terminal Session

Some tools require environment variables and group permissions to refresh.

Recommended:

logout

or restart terminal/WSL after installation.

Step 7: Verify Installation

Check whether tools are installed correctly:

yosys -V
verilator --version
magic
xschem
openroad
openlane
Notes for WSL2 Users
Install WSLg (Recommended)

Windows 11 users already have WSLg support.

For Windows 10:

Install an X Server such as VcXsrv or Xming.
DISPLAY Variable

If GUI tools are not opening:

export DISPLAY=:0
Recommended System Requirements
Component	Recommended
RAM	16 GB or Higher
CPU	4 Cores or Higher
Storage	80 GB Free Space
OS	Ubuntu 22.04 LTS
WSL	WSL2
Troubleshooting
Docker Permission Error

If Docker shows permission denied:

sudo usermod -aG docker $USER

Then logout and login again.

OpenGL / GUI Issues in WSL

Install required packages:

sudo apt install mesa-utils x11-apps -y
Verify Docker
docker run hello-world
Disclaimer

These scripts are intended for educational, research, and development purposes in Open-Source VLSI and ASIC design workflows.

# OpenEDA-Lab

OpenEDA-Lab is a collection of automated shell scripts designed to simplify the installation and setup of Open-Source VLSI and EDA tools on Linux environments.

This repository supports:

* Ubuntu 24 Native
* Ubuntu 24 on VirtualBox
* WSL2 (Windows Subsystem for Linux) (Ubuntu 24)
* Multi-user Linux Lab Systems

The scripts automate the installation and configuration of widely used ASIC design, RTL design, physical design, analog design, and verification tools used in academic, research, and industrial workflows.

## Supported Tools

### Digital Design & Verification

* Yosys
* Verilator
* GTKWave
* Icarus Verilog
* OpenSTA

### Physical Design

* OpenROAD
* OpenLane

### Analog Design

* Magic VLSI
* Xschem
* Ngspice
* Netgen

### PDK Support

* SKY130 OpenPDKs

## Features

* Automated dependency installation
* WSL2-compatible setup
* Docker-based OpenLane environment
* SKY130-enabled launchers for Magic and Xschem
* Parallel compilation support
* Tool verification after installation
* Beginner-friendly installation flow

## Developed By

Mukul Kumar
Junior VLSI Engineer
NIELIT CoE Noida

