#!/bin/bash

# Variables
KAFKA_CONNECT_URL="http://localhost:8083" # Update with your Kafka Connect URL
CONNECTOR_NAME="CDCConnector"

PAYLOAD=$(cat <<- JSON
{
  "name": "$CONNECTOR_NAME", 
  "config": { 
    "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
    "tasks.max": "1", 
    "plugin.name": "pgoutput", 
    "database.hostname": "postgres", 
    "database.dbname": "postgres_db",
    "database.port": "5432",
    "database.user": "postgres_user",
    "database.password": "postgres_password",
    "topic.prefix": "debzcdc",
    "topic.creation.default.replication.factor": 3,
    "topic.creation.default.partitions": 6,
   "producer.override.source.time.field": "value.after.source_time",
    "producer.override.sampling.rate": 0.5,
    "producer.override.source.serializer": "io.confluent.connect.avro.AvroConverter",
    "producer.override.connect.pipeline.id": "CDCPipeline",
    "producer.override.source.value.schema.registry.url": "$CONNECT_VALUE_CONVERTER_SCHEMA_REGISTRY_URL",
    "producer.override.source.value.basic.auth.credentials.source": "USER_INFO",
    "producer.override.source.value.schema.registry.basic.auth.user.info": "$CONNECT_VALUE_CONVERTER_SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO"
  }
}
JSON
)

# Create the connector
curl -s -X POST -H "Content-Type: application/json" --data "$PAYLOAD" "$KAFKA_CONNECT_URL/connectors"

# Output message
if [ $? -eq 0 ]; then
  echo "Successfully created Debezium connector $CONNECTOR_NAME."
else
  echo "Failed to create Debezium connector. Check your Kafka Connect cluster and configurations."
fi

