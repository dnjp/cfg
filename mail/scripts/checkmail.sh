#!/bin/sh

STATE=`nmcli networking connectivity`

if [ $STATE = 'full' ]
then
    ~/.mail/scripts/msmtp-runqueue.sh
    mbsync -a
    notmuch new
    ~/.local/bin/afew -tn
    notmuch tag -inbox tag:inbox AND tag:lists
    exit 0

fi
echo "not connected to the internet"
exit 0
