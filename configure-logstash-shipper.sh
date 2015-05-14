#!/bin/bash
##
# Configures Logstash as a simple shipper
#
# Dependencies:
# - Logstash
# - Redis server (TCP/6379 on 10.10.11.14)
##
set -eux

source env.sh

cp $BASE_PATH/etc/logstash/conf.d/10-input-file-sensu.conf /etc/logstash/conf.d
cp $BASE_PATH/etc/logstash/conf.d/10-input-file-syslog.conf /etc/logstash/conf.d
cp $BASE_PATH/etc/logstash/conf.d/90-output-redis.conf /etc/logstash/conf.d

service logstash restart
