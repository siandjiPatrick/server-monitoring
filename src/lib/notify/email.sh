#!/bin/bash

######## Detect if the script is run in  production or Dev Mode
if [[ -d "/etc/${PACKAGE_NAME}" && -d "/usr/lib/${PACKAGE_NAME}" ]]; then
    ##### Mode package RPM (production)
    EMAIL_CONFIG_FILE="/etc/${PACKAGE_NAME}/email_template.conf"
else
    ##### Mode developpement (repo local)
    EMAIL_CONFIG_FILE="$(readlink -m $(dirname "$0")/../config/email_template.conf)"
fi

echo "Email Config File: ${EMAIL_CONFIG_FILE}"

if [[ -f "$EMAIL_CONFIG_FILE" ]]; then
    source "$EMAIL_CONFIG_FILE"
else
    echo "** Error: email_template.conf not found"
    exit 1
fi

send_email(){

local sender_name="${SENDER_NAME:-"$DEFAULT_SENDER_NAME"}"
local sender_email="${SENDER_EMAIL:-"$DEFAULT_SENDER_EMAIL"}"
local recipient="${RECIPIENT:-"$DEFAULT_RECIPIENT"}"
local subject="${SUBJECT:-"$DEFAULT_SUBJECT"}"
local email_version="${EMAIL_VERSION:-"$DEFAULT_EMAIL_VERSION"}"
local report_filename="${REPORT_FILENAME:-"$DEFAULT_REPORT_FILENAME"}"
local email_template="${EMAIL_BODY:-"$DEFAULT_EMAIL_BODY"}"

sendmail -t <<EOF
From: $sender_name <$sender_email>
To: $recipient 
Subject: $subject
MIME-Version: $email_version
Content-Type: multipart/mixed; boundary="BOUNDARY"

--BOUNDARY
Content-Type: text/html; charset=UTF-8

$email_template

--BOUNDARY
Content-Type: text/plain; name="$(basename "$report_filename")"
Content-Disposition: attachment; filename="$(basename "$report_filename")"
Content-Transfer-Encoding: base64

$(base64 notify/report.txt)

--BOUNDARY--
EOF
}
