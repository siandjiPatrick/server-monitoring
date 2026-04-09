#!/usr/bin/env bash


set -euo pipefail

sendmail -t <<EOF
From: Admin  <admin@gmail.com>
To: asmitterand@yahoo.fr
Subject: Datacenter Monitoring
MIME-Version: 1.0
Content-Type: text/html; charset=UTF-8

<html>
  <body>
    <h2>Rapport Serveur</h2>
    <p style="color:green;"><b>Statut OK</b></p>
  </body>
</html>
EOF
