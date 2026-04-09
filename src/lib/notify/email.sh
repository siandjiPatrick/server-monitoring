#!/bin/bash

EMAIL_CONFIG_FILE="$(dirname "$0")/../config/email_template.conf"
#SCRIPT_PATH="$(readlink -f "$0")"
#SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"

# Détection du mode
#if [ -d /usr/lib/siandjiservmon ]; then
    # Mode package RPM (production)
#    BASE_DIR="/usr/lib/siandjiservmon"
#else
    # Mode développement (repo local)
#    BASE_DIR="$SCRIPT_DIR/.."
#fi

#EMAIL_CONFIG_FILE="$BASE_DIR/config/email_template.conf"
#echo "$EMAIL_CONFIG_FILE"
if [[ -f "$EMAIL_CONFIG_FILE" ]]; then
    source "$EMAIL_CONFIG_FILE"
else
    echo "$(date +%Y-%m-%d-%H:%M:%S) - Error: email_template.conf not found"
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
