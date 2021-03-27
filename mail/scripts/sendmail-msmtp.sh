#!/bin/sh

account=$1

~/.mail/scripts/msmtp-enqueue.sh -oi -f $account -t

