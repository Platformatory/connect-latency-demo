#!/bin/bash

source .env

CONFIG_STRING="bootstrap.servers=$BOOTSTRAP_SERVERS
sasl.jaas.config=$CONNECT_SASL_JAAS_CONFIG
security.protocol=SASL_SSL
sasl.mechanism=PLAIN"

topics_to_delete=$(echo "$CONFIG_STRING" | kafka-topics --bootstrap-server $BOOTSTRAP_SERVERS --list --command-config /dev/stdin | grep -i -E "connect|debzcdc|jdbc")

echo "Topics to delete: $topics_to_delete"

read -p "nuking these topics. (y/N): " confirm
if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
  echo "saved. phew"
  exit 1
fi

echo "$topics_to_delete" | while read -r line; do
  echo "$CONFIG_STRING" | kafka-topics --bootstrap-server $BOOTSTRAP_SERVERS --delete --topic "$line" --command-config /dev/stdin
done

echo "nuked all"

