#!/bin/bash

read -rp "Where are the checksum files?  "
REPLY=${REPLY//\\/\/}
root_letter=`echo ${REPLY:0:1} | tr '[:upper:]' '[:lower:]'`
REPLY='/mnt/'$root_letter'/'${REPLY:3}
echo "The specified dir is: $REPLY"
unset root_letter
cd $REPLY

read -rp "Please specify the regular expression to ONLY select checksum files:  " par
par=`ls -1 | grep \$par$ | tr '\n' ' '`
read -rp "Please select M/m for MD5 sums or S/s for SHA2 sums:  "
REPLY=`echo ${REPLY:0:1} | tr '[:lower:]' '[:upper:]'`
if [ "$REPLY"x = "S"x ]
then
    sha256sum -c $par
elif [ "$REPLY"x = "M"x ]
then
    md5sum -c $par
else
    echo "Input can't be processed!"
fi
unset par
