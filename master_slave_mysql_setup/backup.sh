#!/bin/bash

DIR="/tmp"
MYSQLDUMP="backup.sql"
DATESTAMP=$(date +%d-%m-%Y).tar.gz
filee="$DATESTAMP"
PASSWORD="your sql password here"

# obtain a global lock, recommended for taking backups
mysql -u root -p$PASSWORD --execute="FLUSH TABLES WITH READ LOCK;"

# create a backup
mysqldump -u root -p$PASSWORD --all-databases > $MYSQLDUMP

# remove the global lock
mysql -u root -p$PASSWORD --execute="UNLOCK TABLES;"

# compress the backup to tar.gz
tar -czvf $filee $MYSQLDUMP

######################################################

file="$DATESTAMP"
bucket="holbertonschool40"
resource="/${bucket}/${file}"
contentType="application/x-compressed-tar"
dateValue=`date -R`
stringToSign="PUT\n\n${contentType}\n${dateValue}\n${resource}"
s3Key="your key here"
s3Secret="your secret here"
signature=`echo -en ${stringToSign} | openssl sha1 -hmac ${s3Secret} -binary | base64`
curl -X PUT -T "${file}" \
  -H "Host: ${bucket}.s3.amazonaws.com" \
  -H "Date: ${dateValue}" \
  -H "Content-Type: ${contentType}" \
  -H "Authorization: AWS ${s3Key}:${signature}" \
  https://${bucket}.s3.amazonaws.com/${file}
  
rm -f $MYSQLDUMP $DATESTAMP
