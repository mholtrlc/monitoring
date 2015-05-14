# Monitoring

Set of scripts for evaluating various monitoring stacks (log aggregation, metrics collection, metrics correlation, etc.)

Currently, the following stacks can be installed.

- [Sensu](http://sensuapp.org/) (including [Uchiwa](https://github.com/palourde/uchiwa))
- [Flapjack](http://flapjack.io/)
- [Logstash](http://logstash.net/) (with [Elasticsearch](https://www.elastic.co/products/elasticsearch)/[Kibana](https://www.elastic.co/products/kibana) and [logstash-forwarder](https://github.com/elastic/logstash-forwarder))
- [Heka](https://hekad.readthedocs.org/en/latest/)
- [Sentry](http://sentry.readthedocs.org/en/latest/)
- [Graylog](http://graylog.org/)
- [Statsd](https://github.com/etsy/statsd/)
- [Graphite](https://graphite.readthedocs.org/en/latest/) (with [Grafana](http://grafana.org/))
- [InfluxDB](http://influxdb.com/)
- [Flume](http://flume.apache.org/)
- [Fluentd](http://fluentd.org/)
- [OpenTSDB](http://opentsdb.net/) and [TCollector](http://opentsdb.net/docs/build/html/user_guide/utilities/tcollector.html)

This repository started off from the ideas on my [Monitoring Everything](http://ianunruh.com/2014/05/monitor-everything.html) blog series.

## Goals

Scripts included in this project must:

- Follow best practices for Ubuntu and the applications being installed
- Document service boundaries (ports, sockets, etc.) and default credentials
- Be as minimal as possible
- Be as reusable as possible (middleware and persistence, for example, can be reused between applications)
- Try to stay close to each application's defaults (specifically port numbers and file locations)

This makes it easier for people to solve issues during evaluation, as well as prepare for deploying the applications into staging and production environments.

I won't accept scripts for the following applications. These applications are either too old or too bloated for cloud monitoring.

- Nagios
- Zabbix

## Contributing

Want to add additional scripts? Improve existing scenarios? Just fork it, and submit a pull request. It's that simple.

## Usage

Two Vagrant boxes are provided with this script.

- `monitoring` on 10.10.11.14
- `app1` on 10.10.11.2

The `monitoring` box is intended for the different monitoring stacks, while `app1` is intended to try out clients.

### Sensu/Logstash

The `monitoring` box provides the following:

- [Kibana](http://10.10.11.14:5601)
- [Grafana](http://10.10.11.14:3000)
- [Flapjack](http://10.10.11.14:3080)
- [Uchiwa](http://10.10.11.14:8010)
- [ElasticHQ](http://10.10.11.14:9200/_plugin/HQ)

For client nodes, it provides:

- AMQP (TCP/5672)
- AMQP over SSL (TCP/5671)
- Redis (TCP/6379)
- Statsd (UDP/8125)
- Lumberjack receiver (TCP/5043)
- Graphite line receiver (TCP/2013)
- Graphite Pickle receiver (TCP/2014)

### OpenTSDB

This package provides scripts to install OpenTSDB and TCollector. OpenTSDB depends on HBase, which is installed in [pseudo-distributed mode](http://hbase.apache.org/book.html#distributed) alongside a [standalone ZooKeeper](http://zookeeper.apache.org/doc/r3.1.2/zookeeperStarted.html#sc_InstallingSingleMode).

```sh
vagrant up --no-provision monitoring
vagrant ssh monitoring
```

```sh
sudo -i
cd /vagrant && ./install-all-opentsdb.sh
```

This script also installs Grafana with the OpenTSDB backend configured. Elasticsearch is installed as a dashboard store for Grafana.

- [Grafana](http://10.10.11.14:3000)
- [OpenTSDB dashboard](http://10.10.11.14:4242/)

TCollector is installed on the monitoring host to provide some sample metrics. Note that this script can take more than 10 minutes to install, depending on your bandwidth.

To start collecting metrics from `app1`, simply SSH to it and run the following.

```
sudo -i
cd /vagrant && ./install-tcollector.sh
```

### Sentry

This package provides scripts to install Sentry with the following configuration.

- memcached
- supervisord
- Redis as work queue, update buffer and TSDB
- PostgreSQL as node store

You can use the following to perform the installation.

```sh
vagrant up --no-provision monitoring
vagrant ssh monitoring
```

```sh
sudo -i
cd /vagrant && ./install-all-sentry.sh
```

After installation, the [Sentry web interface](http://10.10.11.14:9000) should be available. Login with the username `admin` and the password `secret`.

### Graylog

To install Graylog with the web interface, simply use the following.

```sh
vagrant up --no-provision monitoring
vagrant ssh monitoring
```

```sh
sudo -i
cd /vagrant && ./install-all-graylog.sh
```

After installation, you can access one the [web interface](http://10.10.11.14:8940/). Use the username `admin` and the password `password`.

### Heka

Heka was created by Mozilla as a lighter alternative to Logstash. This package provides scripts for installing a Heka router that outputs to Elasticsearch.

```sh
vagrant up --no-provision monitoring
vagrant ssh monitoring
```

```sh
sudo -i
cd /vagrant && ./install-all-heka.sh
```

This package provides the following:

- [Heka dashboard](http://10.10.11.14:4352/)
- [Kibana](http://10.10.11.14:5601)
- [ElasticHQ](http://10.10.11.14:9200/_plugin/HQ/)
- Heka Protobuf input on `10.10.11.14` at TCP port 5565

### InfluxDB

[InfluxDB](http://influxdb.org) is an open-source distributed time series database with no external dependencies. This package provides scripts for using InfluxDB as a general replacement for Graphite. It will install Sensu and InfluxDB, configuring Sensu to relay metrics to InfluxDB.

```sh
vagrant up --no-provision monitoring
vagrant ssh monitoring
```

```sh
sudo -i
cd /vagrant && ./install-all-influxdb.sh
```

This package provides the following:

- [Grafana](http://10.10.11.14:3000) configured for InfluxDB
- [InfluxDB admin interface](http://10.10.11.14:8083/) with default credentials
- [Uchiwa](http://10.10.11.14:8010) dashboard for Sensu

Use `vagrant up app1` to start collecting metrics

### Flume

[Flume](http://flume.apache.org) is a distributed, reliable, and available service for efficiently collecting, aggregating, and moving large amounts of log data. This package provides scripts for using Flume with Elasticsearch and receivers for Avro and Syslog protocols.

```sh
vagrant up --no-provision monitoring
vagrant ssh monitoring
```

```sh
sudo -i
cd /vagrant && ./install-all-flume.sh
```

This package provides the following:

- [Kibana](http://10.10.11.14:5601)
- [ElasticHQ](http://10.10.11.14:9200/_plugin/HQ/)
- Avro input on `10.10.11.14` at TCP port 41414
- Syslog input on `10.10.11.14` at TCP port 1514

When using Kibana, you will need to change the index pattern to `[flume-]YYYY-MM-DD`.

### Fluentd

[Fluentd](http://fluentd.org) is an open source data collector to unify log management. This package provides scripts for using Fluentd with Elasticsearch and receivers for Syslog and HTTP protocols.

```sh
vagrant up --no-provision monitoring
vagrant ssh monitoring
```

```sh
sudo -i
cd /vagrant && ./install-all-fluentd.sh
```

This package provides the following:

- [Kibana](http://10.10.11.14:5601)
- [ElasticHQ](http://10.10.11.14:9200/_plugin/HQ/)
- HTTP input on `10.10.11.14` at TCP port 9880
- Syslog input on `10.10.11.14` at TCP port 1514

### Testing Syslog Receivers

To quickly test the functionality of a syslog-compatible receiver, you can use the `logger` command on Ubuntu.

```sh
message="hello world"

# With TCP syslog receiver
logger -n localhost -P 1514 $message

# With UDP syslog receiver
logger -n localhost -P 1514 -d $message
```
