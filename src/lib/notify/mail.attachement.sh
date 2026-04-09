#!/usr/bin/env bash


set -euo pipefail

sendmail -t <<EOF
From: Admin Server <admin@gmail.com>
To: siandjipatrick@yahoo.fr gcptestpatrick@gmail.com 
Subject: Datacenter Monitoring
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="BOUNDARY"


--BOUNDARY
Content-Type: text/html; charset=UTF-8

<html>
  <body>
    <h2>Disk Server Monitoring</h2>
    <p style="color:green;"><b>Statut OK</b></p>
    <ul>
      <li>Disk Usage : $1</li>
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
