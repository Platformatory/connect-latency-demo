#!/bin/bash

source .env

echo "Creating telemetry topic ..."
./setup_kafka_cluster.sh
echo "Telemetry topic created"

echo "Bringing up docker compose environment"
docker-compose up -d

until $(curl --output /dev/null --silent --head --fail http://localhost:8083); do
    echo "Waiting for connect to be healthy..."
    sleep 10
done

echo "Creating JDBC postgres source connector"
./create_jdbc_postgres_source.sh

sleep 20

echo "Creating JDBC MySQL sink connector"
./create_jdbc_mysql_sink.sh

sleep 30

echo "Creating database load"
for i in {1..5}
do
	./create_database_load.sh
done
