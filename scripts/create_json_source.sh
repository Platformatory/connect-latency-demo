#!/bin/bash

CONNECTOR_NAME="JsonSpoolDir"
KAFKA_CONNECT_URL="http://localhost:8083"

CONFIG_JSON=$(cat <<- JSON
{
  "name": "$CONNECTOR_NAME",
  "config": {
    "connector.class": "com.github.jcustenborder.kafka.connect.spooldir.SpoolDirJsonSourceConnector",
    "producer.override.source.time.field": "last_login",
    "producer.override.source.time.format": "yyyy-MM-dd'T'HH:mm:ss'Z'",
    "producer.override.sampling.rate": 0.5,
    "producer.override.source.value.format": "json",
    "producer.override.connect.pipeline.id": "JSONFileToFile",
    "topic": "spooldir-json-topic",
    "input.path": "/home/appuser/data/source",
    "input.file.pattern": "json-spooldir-source.json",
    "error.path": "/home/appuser/data/error",
    "finished.path": "/home/appuser/data/finished",
    "halt.on.error": false,
    "topic.creation.default.replication.factor": 3,
    "topic.creation.default.partitions": 6,
    "value.converter": "org.apache.kafka.connect.json.JsonConverter",
    "key.converter": "org.apache.kafka.connect.json.JsonConverter",
    "schema.generation.enabled": true
  }
}
JSON
)

curl -s -X POST -H "Content-Type: application/json" \
  --data "$CONFIG_JSON" \
  "$KAFKA_CONNECT_URL/connectors"


