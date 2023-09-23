#!/bin/bash
source .env

CONNECT_REST_API="http://localhost:8083/connectors" 
CONNECTOR_NAME="cdc-jdbc-sink-connector" 
JDBC_URL="jdbc:mysql://mysql:3306/mysql_db" 
DB_USER="mysql_user" 
DB_PASSWORD="mysql_password" 
TOPICS_REGEX="debzcdc\\\\.public\\\\..*"

PAYLOAD=$(cat <<EOF
{
  "name": "$CONNECTOR_NAME",
  "config": {
    "connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",
    "tasks.max": "1",
    "connection.url": "$JDBC_URL",
    "connection.user": "$DB_USER",
    "connection.password": "$DB_PASSWORD",
    "topics.regex": "$TOPICS_REGEX",
    "auto.create": "true",
    "insert.mode": "upsert",
    "pk.mode": "record_value",
    "pk.fields": "id",
    "transforms": "unwrap,reroute",
    "transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState",
    "transforms.unwrap.drop.tombstones": "false",
    "transforms.unwrap.delete.handling.mode": "none",
    "transforms.reroute.type": "org.apache.kafka.connect.transforms.RegexRouter",
    "transforms.reroute.regex": "debzcdc\\\\.public\\\\.(.+)",
    "transforms.reroute.replacement": "debzcdc_public_\$1",
    "consumer.override.connect.pipeline.id": "CDCPipeline",
    "consumer.override.telemetry.type": "sink"
  }
}
EOF
)

curl -s -X POST -H "Content-Type: application/json" --data "$PAYLOAD" $CONNECT_REST_API

if [ $? -eq 0 ]; then
  echo "Connector created successfully!"
else
  echo "Failed to create connector!"
  exit 1
fi
