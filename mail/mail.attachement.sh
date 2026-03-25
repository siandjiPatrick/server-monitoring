sendmail -t <<EOF
From: Admin Monitor Server <ton_email@gmail.com>
To: siandjipatrick@yahoo.fr 
Subject: Datacenter Monitoring
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="BOUNDARY"


--BOUNDARY
Content-Type: text/html; charset=UTF-8

<html>
  <body>
    <h2>Rapport Serveur</h2>
    <p style="color:green;"><b>Statut OK</b></p>
    <ul>
      <li>CPU : 10%</li>
      <li>RAM : 12%</li>
    </ul>
    <p>Cordialement,<br>Patrick Siandji</p>
  </body>
</html>

--BOUNDARY
Content-Type: text/plain; name="rapport.txt"
Content-Disposition: attachment; filename="rapport.txt"
Content-Transfer-Encoding: base64

$(base64 rapport.txt)

--BOUNDARY--

EOF
