#!/bin/bash

# Exit immediately if any command fails
set -e

# ==============================================================================
# OS/161 Kernel Build & Run Automation Script
#
# Description:
#   Automates the process of configuring, compiling, installing, and optionally 
#   running an OS/161 kernel. Uses flag arguments for maximum flexibility.
#
# Usage:
#   ./build.sh [-c CONFIG] [-a ACTION] [-t CONF_TEMPLATE]
#
# Options:
#   -c CONFIG        : The kernel configuration name. 
#                      (Default: DUMBVM)
#   -a ACTION        : 'build' to only compile and install, or 'run' to 
#                      compile, install, and immediately launch sys161. 
#                      (Default: build)
#   -t CONF_TEMPLATE : The filename of the sys161.conf sample file. This is 
#                      appended to the default OS/161 tools path.
#                      (Default: sys161.conf.sample)
#
# Examples:
#   ./build.sh                           -> Builds DUMBVM (does not run)
#   ./build.sh -c ASST1                  -> Builds ASST1 (does not run)
#   ./build.sh -a run                    -> Builds DUMBVM and runs it
#   ./build.sh -c ASST2 -a run           -> Builds ASST2 and runs it
#   ./build.sh -a run -t my_custom.conf  -> Builds DUMBVM, runs it, uses custom template
# ==============================================================================

KERNEL_CONFIG="DUMBVM"
ACTION="build"
CONF_TEMPLATE="sys161.conf.sample"

while getopts "c:a:t:" opt; do
  case $opt in
    c) KERNEL_CONFIG="$OPTARG" ;;
    a) ACTION="$OPTARG" ;;
    t) CONF_TEMPLATE="$OPTARG" ;;
    \?) echo "Uso: ./build.sh [-c config] [-a action] [-t template]" >&2
        exit 1 ;;
  esac
done

echo "========================================"
echo " Starting OS/161 Workflow"
echo " Configuration  : $KERNEL_CONFIG"
echo " Action         : $ACTION"
echo " Confi Template : $CONF_TEMPLATE"
echo "========================================"

echo "[1/4] Generating kernel build..."
cd ~/os161/src/kern/conf
./config "$KERNEL_CONFIG"

echo "[2/4] Linking kernel dependencies..."
cd "../compile/$KERNEL_CONFIG"
bmake depend

echo "[3/4] Compiling the kernel..."
bmake

echo "[4/4] Installing the kernel..."
bmake install

if [ "$ACTION" = "run" ]; then
    echo "========================================"
    echo " Launching OS/161 Emulator"
    echo "========================================"
    
    cd ~/os161/root

    if [ ! -f sys161.conf ]; then
        echo "sys161.conf missing in root directory."
        echo "Copying template from: $~/os161/tools/share/examples/sys161/$CONF_TEMPLATE"
        cp "~/os161/tools/share/examples/sys161/$CONF_TEMPLATE" sys161.conf
    fi

    # Launch the emulator
    sys161 kernel
else
    echo "========================================"
    echo " Build complete. (Run skipped)"
    echo "========================================"
fi