#!/bin/bash

CONNECTOR_NAME="JDBCPostgresSource"
KAFKA_CONNECT_URL="http://localhost:8083"

CONFIG_JSON=$(cat <<- JSON
{
  "name": "$CONNECTOR_NAME",
  "config": {
    "connector.class": "io.confluent.connect.jdbc.JdbcSourceConnector",
    "connection.url": "jdbc:postgresql://postgres:5432/postgres_db",
    "connection.user": "postgres_user",
    "connection.password": "postgres_password",
    "producer.override.source.time.field": "CreatedOn",
    "producer.override.source.value.format": "avro",
    "producer.override.connect.pipeline.id": "PostgresToMySQLPipeline",
    "producer.override.source.value.format": "avro",
    "producer.override.source.value.schema.registry.url": $CONNECT_VALUE_CONVERTER_SCHEMA_REGISTRY_URL,
    "producer.override.source.value.basic.auth.credentials.source": USER_INFO,
    "producer.override.source.value.schema.registry.basic.auth.user.info": $CONNECT_VALUE_CONVERTER_SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO,
    "mode": "incrementing",
    "incrementing.column.name": "id",
    "topic.prefix": "jdbc-source-",
    "topic.creation.default.replication.factor": 3,
    "topic.creation.default.partitions": 6,
    "table.whitelist": "orders,users",
    "poll.interval.ms": 60000,
    "batch.max.rows": 100
  }
}
JSON
)

curl -s -X POST -H "Content-Type: application/json" \
  --data "$CONFIG_JSON" \
  "$KAFKA_CONNECT_URL/connectors"


