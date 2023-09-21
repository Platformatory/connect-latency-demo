#!/bin/bash

source .env

CONFIG_STRING="bootstrap.servers=$BOOTSTRAP_SERVERS
sasl.jaas.config=$CONNECT_SASL_JAAS_CONFIG
security.protocol=SASL_SSL
sasl.mechanism=PLAIN"

echo "$CONFIG_STRING" | kafka-topics --bootstrap-server $BOOTSTRAP_SERVERS --create --if-not-exists  --topic connect_latency_telemetry --partitions 6  --command-config /dev/stdin
