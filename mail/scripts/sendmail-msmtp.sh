#!/bin/sh

account=$1
recipient=$2

~/.mail/scripts/msmtp-enqueue.sh -oi -f $account -t

