#!/usr/bin/env bash

set -euo pipefail

source "$(dirname "$0")/.nexus-credential"

MODULE_NAME="siandjiservmon"

NEXUS_SUBDOMAIN="nexus"
NEXUS_DOMAIN="siandji.com"
NEXUS_REPO_PATH="repository"
NEXUS_REPO_NAME="siandji-rpm"

NEXUS_REPO_URL="https://${NEXUS_SUBDOMAIN}.${NEXUS_DOMAIN}/${NEXUS_REPO_PATH}/${NEXUS_REPO_NAME}"

NEXUS_USERNAME="${USERNAME:-}"
NEXUS_PASSWORD="${PASSWORD:-}"


WEBSERVER_HOSTNAME="localhost"
WEBSERVER_REPO_PATH="/var/www/repos/siandji"
WEBSERVER_SSH_KEYDIR="${HOME}/.ssh/${MODULE_NAME}"
WEBSERVER_SSH_OUTPUT_KEYFILE="${WEBSERVER_SSH_KEYDIR}/${MODULE_NAME}"

SCRIPT_DIR="$(dirname "$0")"
PROJECT_DIR="$(readlink -m "${SCRIPT_DIR}/..")"

PACKAGE_DIR="$(readlink -m "${PROJECT_DIR}/../my-Packages")"
RPMBUILD_DIR="${PACKAGE_DIR}/rpmbuild"

ARCHITECTURE="noarch"

GPG_KEYFILE_NAME="RPM-GPG-KEY-${MODULE_NAME}"
GPG_KEYFILE="${PROJECT_DIR}/my-Packages/gpg/${GPG_KEYFILE_NAME}"
if [[ ! -f "$GPG_KEYFILE" ]]; then
    echo "GPG key file not found: $GPG_KEYFILE"
    exit 1
fi

main(){
 	local RPM_PACKAGES
	RPM_PACKAGES="${RPMBUILD_DIR}/RPMS/${ARCHITECTURE}"
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
			for package in "$RPM_PACKAGES"/*;do
				echo "$package"
				[[ -f "$package" ]] || continue
				curl --fail --silent --show-error -u "${NEXUS_USERNAME}:${NEXUS_PASSWORD}" \
				       	--upload-file "$package" \
					"${NEXUS_REPO_URL}/packages/${ARCHITECTURE}/"
			done
			curl --fail --silent --show-error -u "${NEXUS_USERNAME}:${NEXUS_PASSWORD}" \
			       	--upload-file "${GPG_KEYFILE}" \
				"${NEXUS_REPO_URL}/trusted-gpg-keys/"
			;;

		--webserver|-w)
			echo "deploy to webserver ..."
			if [[ ! -f "${WEBSERVER_SSH_OUTPUT_KEYFILE}"  ]];then
				echo "No SSH key found."
    				read -p "Generate SSH key now? (y/n): " answer
				
				if [[ "$answer" == "y" ]]; then
					echo "Installing SSH key on remote server..."
					mkdir -p "${WEBSERVER_SSH_KEYDIR}"
      					ssh-keygen -t ed25519 -N "" \
					           -f "${WEBSERVER_SSH_OUTPUT_KEYFILE}" \
						   -C "ssh Key file for rpm deployment"
    				 else
        				echo "SSH key required for passwordless deploy."
        				exit 1
    				fi

			fi
			#ssh-copy-id -i "${WEBSERVER_SSH_OUTPUT_KEYFILE}.pub" "${WEBSERVER_HOSTNAME}"
			if ! ssh -o BatchMode=yes "${WEBSERVER_HOSTNAME}" "exit" 2>/dev/null; then
  				echo "Installing SSH key on remote server..."
   				ssh-copy-id -i "${WEBSERVER_SSH_OUTPUT_KEYFILE}.pub" "${WEBSERVER_HOSTNAME}"
			fi
			# create remote dirs
			ssh "$WEBSERVER_HOSTNAME" "sudo mkdir -p ${WEBSERVER_REPO_PATH}/packages"
    			ssh "$WEBSERVER_HOSTNAME" "sudo mkdir -p ${WEBSERVER_REPO_PATH}/trusted-gpg-keys"

			for package in "$RPM_PACKAGES"/*.rpm;do
				[[ -e "$package" ]] || continue
				echo "Uploading $package"
				sudo rsync -avz --progress "$package" "${WEBSERVER_HOSTNAME}:${WEBSERVER_REPO_PATH}/packages/"
			done
			sudo rsync -avz --checksum --human-readable "${GPG_KEYFILE}" "${WEBSERVER_HOSTNAME}:${WEBSERVER_REPO_PATH}/trusted-gpg-keys/"
			ssh "$WEBSERVER_HOSTNAME" "sudo createrepo --update ${WEBSERVER_REPO_PATH}"
                        echo "Deployment complete."
			;;
		--all)
			echo "deploying package to nexus and webserver"
			 "$0" --nexus || exit
    			 "$0" --webserver || exit
			;;
		*)
			echo "usage: $0 [ --nexus | --webserver | --all ]"
		esac

}
main "$@"
