#!/usr/bin/env bash


set -euo pipefail

PACKAGE_FORMAT=$(date +%Y-%m-%d-%H:%M:%S)

SCRIPT_DIR="$(dirname "$0")"
PROJECT_DIR="$(readlink -m "${SCRIPT_DIR}/..")"

echo "package script directory : $SCRIPT_DIR"
echo "project directory : $PROJECT_DIR"

PACKAGE_DIR="$(readlink -m "${PROJECT_DIR}/../my-Pacakges")"

PACKAGE_NAME="siandjiservmon"
PACKAGE_VERSION="2.0"
PACKAGE_TAR_FILE="${PACKAGE_NAME}-${PACKAGE_VERSION}.tar.gz"




echo "package directory : $PACKAGE_DIR"
echo "package tar file : $PACKAGE_TAR_FILE"

if [[ ! -e "$PACKAGE_DIR" ]]; then
    mkdir -p "$PACKAGE_DIR"
else
    echo "$PACKAGE_DIR already exists."
fi


if [[ -e "${PACKAGE_DIR}/${PACKAGE_TAR_FILE}" ]]; then
    
    mv "${PACKAGE_DIR}/${PACKAGE_TAR_FILE}" "${PACKAGE_DIR}/${PACKAGE_FORMAT}-${PACKAGE_TAR_FILE}"
fi



# create rpmbuild tree
if [[ ! -e "${PACKAGE_DIR}/rpmbuild" ]]; then
    rpmdev-setuptree
    mv ~/rpmbuild "$PACKAGE_DIR"
fi

# Archive and compress project directory to my-Packages/rpmbuild/SOURCES
tar -czf "${PACKAGE_DIR}/rpmbuild/SOURCES/${PACKAGE_TAR_FILE}" \
    -C "${PROJECT_DIR}/.." \
    "$(basename "${PROJECT_DIR}")"

# cp package spec file to rpmbuild/SPECS
cp -p "${PROJECT_DIR}/package_spec/siandjiservmon.spec" "${PACKAGE_DIR}/rpmbuild/SPECS/"

tree "${PACKAGE_DIR}/rpmbuild"

# create rpm package
echo "rpmbuild ${PACKAGE_DIR}"

rpmbuild --define "_topdir ${PACKAGE_DIR}/rpmbuild" \
        -bb "${PACKAGE_DIR}/rpmbuild/SPECS/siandjiservmon.spec" -v

# show package info
rpm -qpi "${PACKAGE_DIR}/rpmbuild/RPMS/noarch/*"