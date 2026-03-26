#!/bin/bash

DEFAULT_USERNAME=${5:-"Team"}
DEFAULT_STATUS=${6:-"oK"}
DEFAULT_STATUS_COLOR=${7:-"green"}
DEFAULT_MAIL_TITLE=${8:-"Disk Server Monitoring"}
DEFAULT_SENDER="DevOps-Team <devops-team@gmail.com>"
DEFAULT_RECIPIENT="siandjipatrick@yahoo.fr"
DEFAULT_SUBJECT="Patrickstyl - Homelab Monitoring"
DEFAULT_BODY=$(cat << EOF
<html>
  <body>
    <h2>${DEFAULT_MAIL_TITLE}</h2>
    <p style="color:${DEFAULT_STATUS_COLOR};"><b>Status ${DEFAULT_STATUS}</b></p>
    <ul>
      <li>Disk Usage : 23%</li>
      <li>RAM : 12%</li>
      <li>RAM : 12%</li>
      <li>RAM : 12%</li>
    </ul>
    <p>Cordialement,<br>Patrick Siandji</p>
  </body>
</html>

--BOUNDARY
Content-Type: text/plain; name="rapport.txt"
Content-Disposition: attachment; filename="rapport.txt"
Content-Transfer-Encoding: base64

$(base64 mail/rapport.txt)

--BOUNDARY--

EOF
)

TO=${1:-$DEFAULT_RECIPIENT}
SUBJECT=${2:-$DEFAULT_SUBJECT}
FROM=${3:-$DEFAULT_SENDER}
BODY=${4:-$DEFAULT_BODY}

sendmail -t <<EOF
From: ${FROM}
To:   ${TO}
Subject: ${SUBJECT}
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="BOUNDARY"

--BOUNDARY
Content-Type: text/html; charset=UTF-8

${DEFAULT_BODY}

EOF

