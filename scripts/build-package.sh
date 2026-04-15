#!/usr/bin/env bash


set -euo pipefail

PACKAGE_FORMAT=$(date +%Y-%m-%d-%H:%M:%S)

#RELEASE_VERSION=1

SCRIPT_DIR="$(dirname "$0")"
PROJECT_DIR="$(readlink -m "${SCRIPT_DIR}/..")"

echo "package script directory : $SCRIPT_DIR"
echo "project directory : $PROJECT_DIR"

PACKAGE_DIR="$(readlink -m "${PROJECT_DIR}/../my-Packages")"

#PACKAGE_NAME="siandjiservmon"
#PACKAGE_VERSION="1.0.1"
#PACKAGE_TAR_FILE="${PACKAGE_NAME}-${PACKAGE_VERSION}.tar.gz"

RPMBUILD_DIR="${PACKAGE_DIR}/rpmbuild"


echo "package directory : $PACKAGE_DIR"
echo "package tar file : $PACKAGE_TAR_FILE"

if [[ ! -d "$PACKAGE_DIR" ]]; then
    mkdir -p "$PACKAGE_DIR"
else
    echo "$PACKAGE_DIR already exists."
fi


# create rpmbuild tree
if [[ ! -d "${RPMBUILD_DIR}" ]]; then
    echo "rpmbuild_dir : ${RPMBUILD_DIR}"
    rpmdev-setuptree
    mv ~/rpmbuild "$PACKAGE_DIR"
fi

if [[ -e "${RPMBUILD_DIR}/SOURCES/${PACKAGE_TAR_FILE}" ]]; then

    mv "${RPMBUILD_DIR}/SOURCES/${PACKAGE_TAR_FILE}" "${RPMBUILD_DIR}/SOURCES/${PACKAGE_FORMAT}-${PACKAGE_TAR_FILE}"

fi


echo
echo "==============================================================="
echo "Archive and compress project directory to my-Packages/rpmbuild/SOURCES"
echo "==============================================================="
echo


# Archive and compress project directory to my-Packages/rpmbuild/SOURCES
tar -czf "${RPMBUILD_DIR}/SOURCES/${PACKAGE_TAR_FILE}" \
    -C "${PROJECT_DIR}/.." \
    "$(basename "${PROJECT_DIR}")"


echo
echo "==============================================================="
echo "Generate package spec file into rpmbuild/SPECS"
echo "==============================================================="
echo

source ./generate_spec.sh

tree "${RPMBUILD_DIR}"

echo
echo "==============================================================="
echo "Create and push new release $new_version to Remote repository"
echo "==============================================================="
echo

if [[ "$latest_version" != "$new_version" ]];then
	git tag -a "v${new_version}" -m "release v${new_version}"
	git push origin "v${new_version}"
fi

echo
echo "==============================================================="
echo "Create the Package $PACKAGE_NAME"
echo "==============================================================="
echo

# per default rpmbuild build package from ~/rpmbuild,
# we have to indicate where our rpmbuild dir are 
rpmbuild --define "_topdir ${RPMBUILD_DIR}" \
        -ba "${RPMBUILD_DIR}/SPECS/${PACKAGE_NAME}.spec" -v


echo
echo "==============================================================="
echo "Get Informations About the Package"
echo "==============================================================="
echo
# show package info
rpm -qpi "${RPMBUILD_DIR}/RPMS/noarch/*"

echo
echo "==============================================================="
echo "list all Package Files"
echo "==============================================================="
echo

# list Package file
rpm -qpl "${RPMBUILD_DIR}/RPMS/noarch/*"


echo
echo "==============================================================="
echo "Install the Package $PACKAGE_NAME"
echo "==============================================================="
echo

# install Package 
sudo rpm -q "$PACKAGE_NAME" &&  rpm -e "$PACKAGE_NAME"
sudo rpm -ivh "${RPMBUILD_DIR}/RPMS/noarch/*"

