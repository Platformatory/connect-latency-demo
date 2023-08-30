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


