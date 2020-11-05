#!/bin/bash -e
################################################################################
##  File:  basic.sh
##  Desc:  Installs basic command line utilities and dev packages
################################################################################

set -e
# Source the helpers for use with the script
# source $HELPER_SCRIPTS/document.sh
source $HELPER_SCRIPTS/os.sh

set -e

if isUbuntu20 ; then
    echo "Install python2"
    apt-get install -y --no-install-recommends python-is-python2
fi

echo "Install libcurl"
if isUbuntu16 || isUbuntu18; then
   libcurelVer="libcurl3"
fi

if isUbuntu20 ; then
    libcurelVer="libcurl4"
fi

apt-get install -y --no-install-recommends $libcurelVer

# install additional packages only for Ubuntu16.04
if isUbuntu16; then
    common_packages="$common_packages
            libc++-dev
            libc++abi-dev
            libicu55"
fi

toolset="$INSTALLER_SCRIPT_FOLDER/toolset.json"
common_packages=$(jq -r ".apt.common_packages[]" $toolset)
cmd_packages=$(jq -r ".apt.cmd_packages[]" $toolset)
for package in $common_packages $cmd_packages; do
    echo "Install $package"
    apt-get install -y --no-install-recommends $package
done

# Run tests to determine that the software installed as expected
echo "Testing to make sure that script performed as expected, and basic scenarios work"
for cmd in $cmd_packages; do
    if ! command -v $cmd; then
        echo "$cmd was not installed"
        exit 1
    fi
done
