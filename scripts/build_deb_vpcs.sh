#!/bin/bash
CONTROL="/usr/src/eve-ng-public-dev/debian/vpcs_control.template"
SRC_DIR="/usr/src/eve-ng-public-dev"
PATCH_DIR="/usr/src/eve-ng-public-dev/patch"
DISTNAME=$(lsb_release -c -s)
ARCH=$(cat ${CONTROL} | grep Architecture | cut -d: -f2 | sed 's/ //')
BUILD_DIR="/build"
CONTROL_DIR="$(mktemp -dt)"
COMP_DIR="$(mktemp -dt)"
DATA_DIR="$(mktemp -dt)"
VERSION="1.0"
RELEASE="eve-ng"

cat ${CONTROL} | sed "s/%VERSION%/${VERSION}/" | sed "s/%RELEASE%/${RELEASE}/" > ${CONTROL_DIR}/control

# vpcs

cd ${COMP_DIR}
wget "https://sourceforge.net/projects/vpcs/files/0.8/vpcs-0.8-src.tbz"
tar -jxvf vpcs-0.8-src.tbz
cd vpcs-0.8
patch -p 0 < ${PATCH_DIR}/vpcs-0-8b.patch
cd src
make -f Makefile.linux

mkdir -p  ${DATA_DIR}/opt/vpcsu/bin
cp -a vpcs ${DATA_DIR}/opt/vpcsu/bin/
chown -R root:unl ${DATA_DIR}/opt/vpcsu
chmod 777 ${DATA_DIR}/opt/vpcsu/bin/vpcs

# Building the package
cd ${DATA_DIR}
tar czf data.tar.gz *
find -type f -exec md5sum {} \; >> ${CONTROL_DIR}/md5sums
echo 2.0 > ${CONTROL_DIR}/debian-binary
cd ${CONTROL_DIR}
tar czf control.tar.gz md5sums control 
#cd ${SRC_DIR}
mkdir -p ${BUILD_DIR}/apt/pool/${DISTNAME}/e/eve-ng-vpcs
ar -cr ${BUILD_DIR}/apt/pool/${DISTNAME}/e/eve-ng-vpcs/eve-ng-vpcs_${VERSION}-${RELEASE}_${ARCH}.deb ${CONTROL_DIR}/debian-binary ${CONTROL_DIR}/control.tar.gz ${DATA_DIR}/data.tar.gz
rm -rf ${CONTROL_DIR} ${DATA_DIR}
ls -l /build/apt/pool/*/e/eve-ng-vpcs/eve-ng-vpcs_*.deb
