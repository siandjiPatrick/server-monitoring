#!/bin/bash

send_email(){

local sender_name="${DEFAULT_SENDER_NAME:-DevOps-Team}"
local sender_email="${DEFAULT_SENDER_EMAIL:-devops-team@gmail.com}"
local recipient="${DEFAULT_RECIPIENT:-siandjipatrick@yahoo.fr}"
local subject="${DEFAULT_SUBJECT:-Patrickstyl - Homelab Monitoring}"
local email_version="${DEFAULT_EMAIL_VERSION:-1.0}"
local report_filename="${DEFAULT_REPORT_FILENAME:-report.txt}"
local email_template="${DEFAULT_EMAIL_TEMPLATE:-$(cat <<EOF

<html>
  <body>
    <h2>THis IS AN EMAIL TEMPLATE</h2>
    <p style="color:green;"><b>Status OK</b></p>
    <p>Hi Devops-Team,</p>	
    <ul>
      <li>Disk Partition Name : /dev/sda </li>
      <li>Device Typ : Disk </li>
      <li>Mount Point : root(/)</li>
      <li>Disk Filesystem typ : LVM </li>
      <li>Disk Usage on Mount Point : 25%</li>
    </ul>
    <a href="https://proxmox-prod.siandji.com">Click here for more Infos!</a><br>
    <p>Cordialement,<br>Team</p>
  </body>
</html>

EOF
)}"

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
