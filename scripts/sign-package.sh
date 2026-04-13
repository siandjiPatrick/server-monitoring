#!/usr/bin/env bash

set -euo pipefail

source "$(dirname "$0")/.sign-rpm-key"

echo "Signing Key: $RPM_SIGN_KEY"
RPM_SIGNING_KEY=${RPM_SIGN_KEY:-}

if [[ -z $RPM_SIGNING_KEY ]];then
	echo "You have to export RPM_SIGN_KEY"
	exit 1
fi

RPM_DIR="$(realpath "$(dirname "$0")/../../my-Packages/rpmbuild/RPMS/")"


if [[ ! -e "$RPM_DIR" ]];then
	echo "RPM Path $RPM_DIR don't exist !"
	exit 1
fi

for arch in "${RPM_DIR}"/*;do
	echo "$arch"
	for package in "$arch"/*;do
		echo "$package"
		rpmsign --addsign --key-id "$RPM_SIGNING_KEY" "$package"
	        echo "$package sign success !"
	done
done
