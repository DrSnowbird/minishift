#!/bin/bash -x

export PATH=$PWD:$PATH

#https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz

LATEST_VERSION=

GIT_REPO_PATH="openshift/origin"
echo "${GIT_REPO_PATH}"

##############################################
#### ---- Using curl, grep, sed only ---- ####
##############################################
function get_latest_release() {
    LATEST_VERSION=`curl --silent "https://api.github.com/repos/${1}/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":'  |                                             # Get tag line
    sed -E 's/.*"v([^"]+)".*/\1/' `                                   # Pluck JSON value
}

##############################################
#### ---- Using curl, jq(json), sed ##########
##############################################
function get_latest_release_jq() {
    curl --silent "https://api.github.com/repos/${1}/releases/latest" | jq -r '.tag_name'
    LATEST_VERSION=`curl --silent "https://api.github.com/repos/${1}/releases/latest" | jq -r .tag_name | sed 's/^v//' `
}

## github limit the query calls
#if [ `which jq` ]; then
#    echo "---- jq found! ----"
#    get_latest_release_jq ${GIT_REPO_PATH}
#else
#    echo "**** No jq found! ****"
#    get_latest_release ${GIT_REPO_PATH}
#fi 
#echo "LATEST_VERSION=${LATEST_VERSION}"

#CLIENT_TGZ_URL=`curl --silent https://api.github.com/repos/openshift/origin/releases/latest|grep "\"name\": "|grep client | grep "tar.gz" `
#| sed -E 's/.*"([^"]+)".*/\1/' `

CLIENT_TGZ_URL=`curl https://github.com/openshift/origin/releases |grep "client-tools"|grep "tar.gz" |head -1|cut -d'"' -f2`
# https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz

LATEST_VERSION=`echo $(basename ${CLIENT_TGZ_URL}) | sed -E 's/.*\-(v[^-]+)\-.*/\1/' `

TGZ_OBJECT=$(basename ${CLIENT_TGZ_URL})

echo ${TGZ_OBJECT%%.tar.gz}

wget -c "https://github.com/${CLIENT_TGZ_URL}"
tar xvf $(basename ${CLIENT_TGZ_URL})
ln -s ${PWD}/${TGZ_OBJECT%%.tar.gz} client-tools
export PATH=${PWD}/client-tools:$PATH

ACTION=${1:-"start --vm-driver virtualbox"}

# ref: https://docs.okd.io/latest/minishift/getting-started/setting-up-virtualization-environment.html#setting-up-virtualbox-driver
#./minishift start --vm-driver virtualbox

./minishift ${ACTION}

