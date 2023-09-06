# Use Confluent Kafka Connect base image
FROM confluentinc/cp-kafka-connect-base:latest


# Download JDBC Source and Sink connectors
RUN confluent-hub install --no-prompt confluentinc/kafka-connect-jdbc:latest
RUN confluent-hub install --no-prompt debezium/debezium-connector-postgresql:latest
RUN confluent-hub install --no-prompt jcustenborder/kafka-connect-spooldir:latest

RUN mkdir -p /home/appuser/data/source && \
   mkdir -p /home/appuser/data/error && \
   mkdir -p /home/appuser/data/finished

# This doesn't work
RUN cd /usr/share/java/ && curl https://cdn.mysql.com//Downloads/Connector-J/mysql-connector-j-8.1.0.tar.gz | tar xz

# Colocate it with the JDBC Connector
RUN cp /usr/share/java/mysql-connector-j-8.1.0/mysql-connector-j-8.1.0.jar /usr/share/confluent-hub-components/confluentinc-kafka-connect-jdbc/lib
