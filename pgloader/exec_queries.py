import argparse
import psycopg2
import time

# Set up the database connection
conn = psycopg2.connect(database="postgres_db", user="postgres_user", password="postgres_password", host="postgres", port="5432")
cur = conn.cursor()

# Set up the command line arguments
parser = argparse.ArgumentParser()
parser.add_argument("--query-file", type=str, required=True, help="The name of the file containing the queries to execute")
parser.add_argument("--num-loops", type=int, default=1, help="The number of loops to execute the queries")
parser.add_argument("--sleep-interval", type=float, default=0.1, help="The number of seconds to sleep between queries")
args = parser.parse_args()

# Read the queries from the file
with open(args.query_file, "r") as f:
    queries = f.read().splitlines()

# Execute the queries in a loop
for i in range(args.num_loops):
    print(f"Executing loop {i}.....")
    for query in queries:
        cur.execute(query)
        conn.commit()
        #print(f"Sleeping for {args.sleep_interval}.....")
        #time.sleep(args.sleep_interval)

# Close the database connection
cur.close()
conn.close()
