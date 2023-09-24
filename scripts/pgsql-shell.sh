#!/bin/bash
docker-compose exec postgres bash -c "PGPASSWORD=postgres_password psql -U postgres_user -p 5432 -h postgres postgres_db"

