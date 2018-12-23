#!/bin/bash -x

ACTION=${1:-"start --vm-driver virtualbox"}

# ref: https://docs.okd.io/latest/minishift/getting-started/setting-up-virtualization-environment.html#setting-up-virtualbox-driver
#./minishift start --vm-driver virtualbox
export PATH=$PWD:$PATH
./minishift ${ACTION}

