#!/bin/bash
##
# Installs Logstash forwarder, a lightweight log shipper
#
# Dependencies:
# - Lumberjack receiver (TCP/5043 on 10.10.11.14)
# - SSL certificate generated with `generate-lumberjack-ssl.sh`
##
set -eux

source env.sh
BUILD_PATH=$BASE_PATH/build

cd /tmp

apt-get install -yq git golang

git clone git://github.com/elasticsearch/logstash-forwarder.git
cd logstash-forwarder
go build

cp logstash-forwarder /usr/bin

mkdir -p /etc/logstash-forwarder

cp $BASE_PATH/etc/init/logstash-forwarder.conf /etc/init
cp $BASE_PATH/etc/logstash-forwarder/config.json /etc/logstash-forwarder

cp $BUILD_PATH/forwarder.crt $BUILD_PATH/forwarder.key /etc/logstash-forwarder
chmod 640 /etc/logstash-forwarder/forwarder.key

service logstash-forwarder start
