#!/bin/bash

echo "5 records from jdbc-source-orders"

docker-compose exec -it mysql mysql -u mysql_user -pmysql_password mysql_db -e 'SELECT * FROM `jdbc-source-orders` LIMIT 5;'

echo "5 records from jdbc-source-users"

docker-compose exec -it mysql mysql -u mysql_user -pmysql_password mysql_db -e 'SELECT * FROM `jdbc-source-users` LIMIT 5;'
