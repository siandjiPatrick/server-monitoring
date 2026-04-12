# =================== VARIABLE ###############################
APP = server-monitoring
NEXUS_REPO_NAME = siandji-rpm
NEXUS_URL = nexus.siandji.com
NEXUS_TOKEN = ""
NEXUS_USERNAME = ""

WEBSERVER_HOSTNAME = httpd.local

.PHONY: help build package sign-package deploy-to-nexus deploy-to-webserver test clean 

###################### DEFAULT TARGET ########################
.DEFAULT_GOAL := help

###################### HELP ##################################
help:
	@echo ""
	@echo "Available targets:"
	@echo "  make build                    - Build the project"
	@echo "  make package                  - package and generate rpm"
	@echo "  make sign-package             - Sign rpm Package"
	@echo "  make deploy-to-nexus          - Deploy Package to nexus repository"
	@echo "  make deploy-to-webserver      - Deploy Package to httpd webserver"
	@echo "  make test                     - Test rpm Package"
	@echo "  make clean                    - Clean project"
	@echo "  make help                     - Show this help"
	@echo ""

###################### BUILD #################################
build:
	@echo "Building project $(APP)..."
	@bash scripts/build-package.sh

###################### GENERATE RPM PACKAGE  #################
package:
	@echo "package project $(APP)..."
	@bash scripts/build-package.sh

####################### SIGN PACKAGE #########################
sign-package:
	@echo "Sign package ..."

####################### DEPLOY ###############################
deploy-to-nexus:
	@echo "deploy package to nexus repository..."
	@bash scripts/deploy-package.sh --nexus
####################### DEPLOY TO WEBSERVER ##################
deploy-to-webserver:
	@echo "deploy package to httpd webserver..."
	@bash scripts/deploy-package.sh --webserver
####################### TEST ##################################
test:
	@echo "Running tests..."

####################### CLEAN #################################
clean:
	@echo "Cleaning project..."
	@bash -c "rm -rf /var/www/repos/siandji/*"


