#!/bin/bash
source .env

CONFIG_STRING="bootstrap.servers=$BOOTSTRAP_SERVERS
sasl.jaas.config=$CONNECT_SASL_JAAS_CONFIG
security.protocol=SASL_SSL
sasl.mechanism=PLAIN"

echo "$CONFIG_STRING" | kafka-topics --bootstrap-server $BOOTSTRAP_SERVERS --create --if-not-exists  --topic $TELEMETRY_TOPIC --partitions 6  --command-config /dev/stdin

# Create the schema

curl -X POST "$CONNECT_VALUE_CONVERTER_SCHEMA_REGISTRY_URL/subjects/$TELEMETRY_TOPIC-value/versions?normalize=false" \
-u "$CONNECT_VALUE_CONVERTER_SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO" \
-H 'Content-Type: application/vnd.schemaregistry.v1+json' \
-d '{"schema": "{\"type\": \"record\", \"name\": \"Timestamps\", \"namespace\": \"com.platformatory.kafka.connect.latencyanalyzer\", \"fields\": [{\"type\": \"string\", \"name\": \"correlation_id\"}, {\"type\": \"string\", \"name\": \"connect_pipeline_id\"}, {\"type\": \"string\", \"name\": \"timestamp_type\"}, {\"type\": \"long\", \"name\": \"timestamp\"}]}", "schemaType": "AVRO"}'
