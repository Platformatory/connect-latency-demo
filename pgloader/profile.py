#!/usr/bin/env python3

import argparse
import pymysql
import psycopg2
import numpy as np
import csv
from datetime import datetime
import random

# Parse command-line arguments
parser = argparse.ArgumentParser()
parser.add_argument("--mysql-host", default="mysql", help="MySQL host")
parser.add_argument("--mysql-user", default="mysql_user", help="MySQL user")
parser.add_argument("--mysql-password", default="mysql_password", help="MySQL password")
parser.add_argument("--mysql-db", default="mysql_db", help="MySQL database")
parser.add_argument("--postgres-host", default="postgres", help="PostgreSQL host")
parser.add_argument("--postgres-user", default="postgres_user", help="PostgreSQL user")
parser.add_argument("--postgres-password", default="postgres_password", help="PostgreSQL password")
parser.add_argument("--postgres-db", default="postgres_db", help="PostgreSQL database")
parser.add_argument("--tables", type=str, required=True, help="Comma-separated list of table names")
parser.add_argument("--sampling-fraction", type=float, default=0.1, help="Sampling fraction")
parser.add_argument("--output-csv", type=str, default="/app/latency.csv", help="Output CSV file path")
args = parser.parse_args()

# Initialize MySQL connection
mysql_conn = pymysql.connect(
    host=args.mysql_host,
    user=args.mysql_user,
    password=args.mysql_password,
    database=args.mysql_db
)
mysql_cursor = mysql_conn.cursor()

# Initialize PostgreSQL connection
postgres_conn = psycopg2.connect(
    host=args.postgres_host,
    user=args.postgres_user,
    password=args.postgres_password,
    database=args.postgres_db
)
postgres_cursor = postgres_conn.cursor()

# Initialize CSV writer
with open(args.output_csv, 'w', newline='') as csvfile:
    csv_writer = csv.writer(csvfile)
    csv_writer.writerow(['Table', 'Primary_Key', 'Sink_Time', 'Source_Time', 'Latency'])

    for table in args.tables.split(","):
        # Get all primary keys from MySQL with table prefix "jdbc-source-" and quoted table name
        mysql_cursor.execute(f"SELECT id FROM `jdbc-source-{table}`")
        mysql_keys = set(row[0] for row in mysql_cursor.fetchall())
        #print(mysql_keys)

        # Get all primary keys from PostgreSQL
        postgres_cursor.execute(f"SELECT id FROM \"{table}\"")
        postgres_keys = set(row[0] for row in postgres_cursor.fetchall())
        #print(postgres_keys)

        # Get the intersection of primary keys and sample
        common_keys = list(mysql_keys & postgres_keys)
        print(common_keys)
        sampled_keys = random.sample(common_keys, int(len(common_keys) * args.sampling_fraction))

        # Fetch data for sampled keys from MySQL and PostgreSQL
        for key in sampled_keys:
            mysql_cursor.execute(f"SELECT id, sink_time FROM `jdbc-source-{table}` WHERE id = {key}")
            mysql_row = mysql_cursor.fetchone()

            postgres_cursor.execute(f"SELECT id, source_time FROM {table} WHERE id = {key}")
            postgres_row = postgres_cursor.fetchone()

            if mysql_row and postgres_row:
                primary_key, sink_time = mysql_row
                _, source_time = postgres_row

                latency = (sink_time - source_time).total_seconds()
                csv_writer.writerow([table, primary_key, sink_time, source_time, latency])

# Close connections
mysql_conn.close()
postgres_conn.close()

