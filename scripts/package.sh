#!/usr/bin/env bash


set -euo pipefail

PACKAGE_FORMAT=$(date +%Y-%m-%d-%H:%M:%S)

SCRIPT_DIR="$(dirname "$0")"
PROJECT_DIR="$(readlink -m "${SCRIPT_DIR}/..")"

echo "package script directory : $SCRIPT_DIR"
echo "project directory : $PROJECT_DIR"

PACKAGE_DIR="$(readlink -m "${PROJECT_DIR}/../my-Pacakges")"

PACKAGE_NAME="siandjiservmon"
PACKAGE_VERSION="1.0"
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


echo
echo "==============================================================="
echo "Archive and compress project directory to my-Packages/rpmbuild/SOURCES"
echo "==============================================================="
echo


# Archive and compress project directory to my-Packages/rpmbuild/SOURCES
tar -czf "${PACKAGE_DIR}/rpmbuild/SOURCES/${PACKAGE_TAR_FILE}" \
    -C "${PROJECT_DIR}/.." \
    "$(basename "${PROJECT_DIR}")"


echo
echo "==============================================================="
echo "cp package spec file into rpmbuild/SPECS"
echo "==============================================================="
echo

# cp package spec file to rpmbuild/SPECS
cp -p "${PROJECT_DIR}/package_spec/siandjiservmon.spec" "${PACKAGE_DIR}/rpmbuild/SPECS/"

tree "${PACKAGE_DIR}/rpmbuild"

# create rpm package
#echo "rpmbuild ${PACKAGE_DIR}"

echo
echo "==============================================================="
echo "Create the Package $PACKAGE_NAME"
echo "==============================================================="
echo

# per default rpmbuild build package from ~/rpmbuild,
# we have to indicate where our rpmbuild dir are 
rpmbuild --define "_topdir ${PACKAGE_DIR}/rpmbuild" \
        -ba "${PACKAGE_DIR}/rpmbuild/SPECS/siandjiservmon.spec" -v


echo
echo "==============================================================="
echo "Get Informations About the Package"
echo "==============================================================="
echo
# show package info
rpm -qpi "${PACKAGE_DIR}/rpmbuild/RPMS/noarch/*"

echo
echo "==============================================================="
echo "list all Package Files"
echo "==============================================================="
echo

# list Package file
rpm -qpl "${PACKAGE_DIR}/rpmbuild/RPMS/noarch/*"


echo
echo "==============================================================="
echo "Install the Package $PACKAGE_NAME"
echo "==============================================================="
echo

# list Package file
#sudo rpm -ivh "${PACKAGE_DIR}/rpmbuild/RPMS/noarch/*"
