#!/bin/bash

CONNECTOR_NAME="JDBCPostgresSource"
KAFKA_CONNECT_URL="http://localhost:8083"


curl -s -X DELETE "$KAFKA_CONNECT_URL/connectors/$CONNECTOR_NAME"
