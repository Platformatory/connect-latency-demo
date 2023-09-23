#!/usr/bin/env python3

import argparse
import pymysql
import csv
import random
from datetime import datetime

# Parse command-line arguments
parser = argparse.ArgumentParser()
parser.add_argument("--mysql-host", default="mysql", help="MySQL host")
parser.add_argument("--mysql-user", default="mysql_user", help="MySQL user")
parser.add_argument("--mysql-password", default="mysql_password", help="MySQL password")
parser.add_argument("--mysql-db", default="mysql_db", help="MySQL database")
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

# Initialize CSV writer
with open(args.output_csv, 'w', newline='') as csvfile:
    csv_writer = csv.writer(csvfile)
    csv_writer.writerow(['Table', 'Primary_Key', 'Sink_Time', 'Source_Time', 'Latency'])

    for table in args.tables.split(","):
        # Get all primary keys from MySQL
        mysql_cursor.execute(f"SELECT id FROM `{table}`")
        mysql_keys = [row[0] for row in mysql_cursor.fetchall()]
        
        # Sample keys based on the sampling fraction
        sampled_keys = random.sample(mysql_keys, int(len(mysql_keys) * args.sampling_fraction))

        # Fetch data for sampled keys from MySQL and calculate latency
        for key in sampled_keys:
            mysql_cursor.execute(f"SELECT id, sink_time, source_time FROM `{table}` WHERE id = {key}")
            mysql_row = mysql_cursor.fetchone()

            if mysql_row:
                primary_key, sink_time, source_time = mysql_row
                latency = (sink_time - source_time).total_seconds()
                csv_writer.writerow([table, primary_key, sink_time, source_time, latency])

# Close connection
mysql_conn.close()

print("Script completed.")
