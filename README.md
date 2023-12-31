# Kafka Connect Latency Demo Sandbox

## Setup

### Environment variables

```bash
export BOOTSTRAP_SERVERS=
export CONNECT_SASL_JAAS_CONFIG=
export CONNECT_VALUE_CONVERTER_SCHEMA_REGISTRY_URL=
export CONNECT_VALUE_CONVERTER_SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO=

export TELEMETRY_TOPIC=connect_latency_telemetry

# For the KSQL service (comma-separated list of topics)
export INPUT_TOPICS=$TELEMETRY_TOPIC
```

> Certain scripts expect the environment variables in a `.env` file. Place the above snippet in a `.env` file before using the scripts

**Note**: Topics should be a list of comma separated string without spaces

## Start

### Start demo

> This assumes that the environment is fresh and does not have previously configured connectors(configured through the script) since the script also creates the connectors through the script.

```bash
./start-demo.sh
```


### Manually

```bash
docker-compose up -d
```

### Generate database load for postgres

```sh
./create_database_load.sh
```

## Create connectors

```sh
# Postgres source connector
./create_jdbc_postgres_source.sh

# MySQL sink connector
./delete_jdbc_mysql_sink.sh

# Debezium connectors
./create_cdc_connector.sh
# Run the database load script again to generate from updates to the database tables
./create_database_load.sh
```

## Verify working of the connectors

```sh
# Verify postgres data sourced to Kafka
# Requires kafka-avro-console-consumer to be in the path
# Displays 10 messages in the topics. Run the database load script parallely to generate data
./verify_postgres_source_data.sh

# Verify MySQL sink
# Displays the first 5 records in the table
./verify_mysql_sink_data.sh

# Verify CDC data in the Kafka topic
# Displays 10 messages in the topics. Run the database load script parallely to generate data
./verify_cdc_data.sh
```

## Delete connectors

```sh
./delete_jdbc_postgres_source.sh

./delete_jdbc_mysql_sink.sh

./delete_cdc_connector.sh
```

## Destory environment

```sh
# Run the delete scripts to remove the connectors from the kafka brokers
docker-compose down -v

./clean_kafka_cluster.sh
```

