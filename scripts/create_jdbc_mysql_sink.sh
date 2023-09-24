#!/bin/bash
source .env
# Variables
KAFKA_CONNECT_URL="http://localhost:8083"  # Update with your Kafka Connect URL
CONNECTOR_NAME="JDBCMysqlSink"

# JSON payload for the connector
CONFIG_JSON=$(cat <<- JSON
{
  "name": "$CONNECTOR_NAME",
  "config": {
    "connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",
    "connection.url": "jdbc:mysql://mysql:3306/mysql_db",
    "tasks.max": 4,
    "connection.user": "mysql_user",
    "connection.password": "mysql_password",
    "auto.create": "true",
    "topics.regex": "jdbc-source-.*",
    "consumer.override.connect.pipeline.id": "PostgresToMySQLPipeline",
    "consumer.override.telemetry.type": "sink"
  }
}
JSON
)

# Create the connector
curl -s -X POST -H "Content-Type: application/json" --data "$CONFIG_JSON" "$KAFKA_CONNECT_URL/connectors"

# Output message
if [ $? -eq 0 ]; then
  echo ""
  echo "Successfully created MySQL JDBC Sink connector $CONNECTOR_NAME."
else
  echo ""
  echo "Failed to create MySQL JDBC Sink connector. Check your Kafka Connect cluster and configurations."
fi

