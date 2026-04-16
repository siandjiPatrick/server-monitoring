#!/bin/bash
set -eou pipefail

PACKAGE_NAME="siandjiservmon"


#################  get the latest version
latest_version=$(git tag --list "v*" | sort -V | tail -n 1 | sed 's/v//')

if [ -z "$latest_version" ]; then
  latest_version="1.0.0"
fi
echo "Last version: $latest_version"

IFS='.' read -a version_arr <<< "$latest_version"

major="${version_arr[0]}"
minor="${version_arr[1]}"
patch="${version_arr[2]}"

new_version="$latest_version"
################# generate new release version
case "${1:-}" in 
	--patch)
		#echo "old patch version $patch"
		echo "patch version in process ..."
		patch=$((patch+1))
		#echo "new patch version = $patch" 
		new_version="${major}.${minor}.${patch}"
		;;
	--minor)
		#echo "old minor version $minor"
                echo "minor version in process ..."
		minor=$((minor+1))
		#echo "minor = $minor" 
		new_version="${major}.${minor}.${patch}"
		;;
	--major)
		#echo "old major version $major"
                echo "major version in process ..."
		major=$((major+1))
		#echo "major = $major" 
		new_version="${major}.${minor}.${patch}"
		;;
	*)
		echo "Aktuelle Version :  $latest_version"
		#echo "§usage: $(basename "$0") [ --patch | --minor | --major ]"
		#exit 1
		;;
	esac

echo "release Version = $new_version"

PACKAGE_TAR_FILE="${PACKAGE_NAME}-${new_version}.tar.gz"

echo "package Tar Filename = $PACKAGE_TAR_FILE"

. "$(dirname "$0")/build-package.sh" 

