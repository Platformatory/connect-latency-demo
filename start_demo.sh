#!/bin/bash
set -e  # Exit on any error
source .env  # Source .env from the script's directory

./scripts/setup_kafka_cluster.sh
echo "Prepped Kafka Cluster, including Telemetry topic"

echo "Bringing up docker compose environment"
docker-compose up -d

until $(curl --output /dev/null --silent --head --fail http://localhost:8083); do
    echo "Waiting for connect to be healthy..."
    sleep 10
done

echo "Creating JDBC postgres source connector"
./scripts/create_jdbc_postgres_source.sh

SLEEP_DURATION=${SLEEP_DURATION:-20}  # Use the value of SLEEP_DURATION if set, otherwise default to 20
sleep $SLEEP_DURATION

echo "Creating JDBC MySQL sink connector"
./scripts/create_jdbc_mysql_sink.sh

SLEEP_DURATION=${SLEEP_DURATION:-30}  # Use the value of SLEEP_DURATION if set, otherwise default to 30
sleep $SLEEP_DURATION

echo "Creating database load"
for i in {1..5}
do
  ./scripts/create_database_load.sh
done

