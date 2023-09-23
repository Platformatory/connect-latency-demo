#!/bin/bash
docker-compose exec mysql bash -c "mysql -u root -pmysql_root_password mysql_db"

