#!/usr/bin/env bash

set -euo pipefail

source "$(dirname "$0")/.nexus-credential"

#APP_NAME="server-monitoring"

NEXUS_SUBDOMAIN="nexus"
NEXUS_DOMAIN="siandji.com"
NEXUS_REPO_PATH="repository"
NEXUS_REPO_NAME="siandji-rpm"

NEXUS_REPO_URL="https://${NEXUS_SUBDOMAIN}.${NEXUS_DOMAIN}/${NEXUS_REPO_PATH}/${NEXUS_REPO_NAME}"

NEXUS_USERNAME="${USERNAME:-}"
NEXUS_PASSWORD="${PASSWORD:-}"


WEBSERVER_HOSTNAME="localhost"
REPO_PATH=""


main(){
 	local RPM_PACKAGES
	RPM_PACKAGES="$(realpath "$(dirname "$0")/../../my-Packages/rpmbuild/RPMS/noarch/siandjiservmon-1.0.1-1.el9.noarch.rpm")"
	case "${1:-}" in
		--nexus|-n)
			
			if [[ -z "$NEXUS_USERNAME" || -z "$NEXUS_PASSWORD" ]];then
				echo "username or password not defined."
				echo "Please set the Variable USERNAME AND PASSWOR for the Nexus repository"
				exit 1
			fi
			echo "deploy to nexus ..."
			echo "RPM PACKAGE NAME --> $RPM_PACKAGES"
		        echo "nexus repo url --> ${NEXUS_REPO_URL}"
			for package in "$RPM_PACKAGES";do
				echo "$package"
				curl -u "${NEXUS_USERNAME}:${NEXUS_PASSWORD}" --upload-file "$package" "${NEXUS_REPO_URL}/packages/"
			done
			;;
		--webserver|-w)
			echo "deploy to webserver ..."
		        scp $RPM_PACKAGES "${WEBSERVER_HOSTNAME}:/var/www/repos/siandji/" 	
			#createrepo_c /var/www/repos/siandji/
			;;
		*)
			echo "usage: $0 [ --nexus | --webserver ]"
		esac

}
main "$@"
