#!/bin/bash
set -e  # Exit on any error

if [ -z "$1" ]; then
    echo "Usage: $0 <Pipeline>"
    echo "Pipeline can be either jdbc-jdbc or cdc-jdbc"
    exit 1
fi

Pipeline=$1  # Store the first argument in a variable named Pipeline

source .env  # Source .env from the script's directory

./scripts/setup_kafka_cluster.sh
echo "Prepped Kafka Cluster, including Telemetry topic"

echo "Bringing up docker compose environment"
docker-compose up -d

until $(curl --output /dev/null --silent --head --fail http://localhost:8083); do
    echo "Waiting for connect to be healthy..."
    sleep 10
done

if [ "$Pipeline" == "jdbc-jdbc" ]; then
    echo "Creating JDBC postgres source connector"
    ./scripts/create_jdbc_postgres_source.sh
    
    SLEEP_DURATION=${SLEEP_DURATION:-20}  # Use the value of SLEEP_DURATION if set, otherwise default to 20
    sleep $SLEEP_DURATION
    
    echo "Creating JDBC MySQL sink connector"
    ./scripts/create_jdbc_mysql_sink.sh
elif [ "$Pipeline" == "cdc-jdbc" ]; then
    echo "Creating CDC connector"
    ./scripts/create_cdc_connector.sh
    
    SLEEP_DURATION=${SLEEP_DURATION:-20}  # Use the value of SLEEP_DURATION if set, otherwise default to 20
    sleep $SLEEP_DURATION
    
    echo "Creating JDBC MySQL sink connector for CDC"
    ./scripts/create_jdbc_mysql_sink_cdc.sh
else
    echo "Invalid value for Pipeline: $Pipeline. It must be either jdbc-jdbc or cdc-jdbc"
    exit 1
fi

SLEEP_DURATION=${SLEEP_DURATION:-30}  # Use the value of SLEEP_DURATION if set, otherwise default to 30
sleep $SLEEP_DURATION

echo "Creating database load"
./scripts/create_database_load.sh
