#!/bin/bash
# Copyright 2013 Red Beacon, Inc. - All Rights Reserved
#
# Author: Billy McCarthy

uid=`id -u $USER`
port=`expr 40000 + $uid`

pkill -U $uid -f 'manage.py runserver'
/opt/bin/jekyll serve --watch -P $port --baseurl=/blog/
