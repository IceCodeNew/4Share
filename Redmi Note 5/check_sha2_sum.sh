#!/bin/bash

read -rp "Where are the checksum files? "
REPLY=${REPLY//\\/\/}
root_letter=`echo ${REPLY:0:1} | tr '[:upper:]' '[:lower:]'`
REPLY='/mnt/'$root_letter'/'${REPLY:3}
echo "The specified dir is: $REPLY"
unset root_letter

cd $REPLY
par=`ls -1 | grep .sha2 | tr '\n' ' '`
sha256sum -c $par
