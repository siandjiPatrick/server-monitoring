#!/bin/bash

DEFAULT_USERNAME=${5:-"Team"}
DEFAULT_STATUS=${6:-"oK"}
DEFAULT_STATUS_COLOR=${7:-"green"}
DEFAULT_MAIL_TITLE=${8:-"Disk Server Monitoring"}

DISK_PART_NAME=${9:-""}
DEVICE_TYPE=${10:-""}
MOUNT_POINT=${11:-""}
DISK_FS_TYP=${12:-""}
DISK_USAGE=${13:-""}
ATTACHEMENT_FILENAME=${14:-"rapport.txt"}
FILNAME_DIR=${15:-"mail"}


DEFAULT_SENDER="DevOps-Team <devops-team@gmail.com>"
DEFAULT_RECIPIENT="siandjipatrick@yahoo.fr"
DEFAULT_SUBJECT="Patrickstyl - Homelab Monitoring"
TO=${1:-$DEFAULT_RECIPIENT}
SUBJECT=${2:-$DEFAULT_SUBJECT}
FROM=${3:-$DEFAULT_SENDER}

DEFAULT_BODY=$(cat << EOF
<html>
  <body>
    <h2>${DEFAULT_MAIL_TITLE}</h2>
    <p style="color:${DEFAULT_STATUS_COLOR};"><b>Status ${DEFAULT_STATUS}</b></p>
    <p>Hi ${DEFAULT_USERNAME},</p>	
    <ul>
      <li>Disk Partition Name : ${DISK_PART_NAME}</li>
      <li>Device Typ : ${DEVICE_TYPE}</li>
      <li>Mount Point : ${MOUNT_POINT}</li>
      <li>Disk Filesystem typ : ${DISK_FS_TYP}</li>
      <li>Disk Usage on Mount Point : ${DISK_USAGE}</li>
    </ul>
    <a href="https://proxmox-prod.siandji.com">Click here for more Infos!</a><br>
    <p>Cordialement,<br>${FROM}</p>
  </body>
</html>

--BOUNDARY
Content-Type: text/plain; name="${ATTACHEMENT_FILENAME}"
Content-Disposition: attachment; filename="${ATTACHEMENT_FILENAME}"
Content-Transfer-Encoding: base64

$(base64 "${FILNAME_DIR}/${ATTACHEMENT_FILENAME}")

--BOUNDARY--

EOF
)

BODY=${4:-$DEFAULT_BODY}

# send an E-Mail with predefined Parameters
sendmail -t <<EOF
From: ${FROM}
To:   ${TO}
Subject: ${SUBJECT}
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="BOUNDARY"

--BOUNDARY
Content-Type: text/html; charset=UTF-8

${BODY}

EOF

