#!/bin/bash

source .env

CONFIG_STRING="bootstrap.servers=$BOOTSTRAP_SERVERS
sasl.jaas.config=$CONNECT_SASL_JAAS_CONFIG
security.protocol=SASL_SSL
sasl.mechanism=PLAIN"

echo "$CONFIG_STRING" | kafka-topics --bootstrap-server $BOOTSTRAP_SERVERS --create --if-not-exists  --topic test_topic --partitions 6  --command-config /dev/stdin

curl -X POST $CONNECT_VALUE_CONVERTER_SCHEMA_REGISTRY_URL/subjects/test_topic-value/versions\?normalize=false -u $CONNECT_VALUE_CONVERTER_SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO -H 'Content-Type: application/vnd.schemaregistry.v1+json' -d '@schema-connect_latency_telemetry-value.json'