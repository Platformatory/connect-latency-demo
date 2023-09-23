#!/bin/bash

echo "Consuming from the topic debzcdc.public.orders"

kafka-avro-console-consumer --bootstrap-server $BOOTSTRAP_SERVERS --consumer-property security.protocol=SASL_SSL --consumer-property sasl.mechanism=PLAIN --consumer-property sasl.jaas.config="$CONNECT_SASL_JAAS_CONFIG" --property schema.registry.url=$CONNECT_VALUE_CONVERTER_SCHEMA_REGISTRY_URL --property schema.registry.basic.auth.user.info=$CONNECT_VALUE_CONVERTER_SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO --property schema.registry.basic.auth.credentials.source=USER_INFO --max-messages 10 --topic debzcdc.public.orders


echo "Consuming from the topic debzcdc.public.users"

kafka-avro-console-consumer --bootstrap-server $BOOTSTRAP_SERVERS --consumer-property security.protocol=SASL_SSL --consumer-property sasl.mechanism=PLAIN --consumer-property sasl.jaas.config="$CONNECT_SASL_JAAS_CONFIG" --property schema.registry.url=$CONNECT_VALUE_CONVERTER_SCHEMA_REGISTRY_URL --property schema.registry.basic.auth.user.info=$CONNECT_VALUE_CONVERTER_SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO --property schema.registry.basic.auth.credentials.source=USER_INFO --max-messages 10 --topic debzcdc.public.users
