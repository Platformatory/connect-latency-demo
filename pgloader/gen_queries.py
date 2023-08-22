import argparse
from faker import Faker
import psycopg2
import random
from datetime import datetime

# Initialize Faker and database connection
fake = Faker()
conn = psycopg2.connect(database="postgres_db", user="postgres_user", password="postgres_password", host="postgres", port="5432")
cur = conn.cursor()

# Parse command line arguments
parser = argparse.ArgumentParser()
parser.add_argument("--num-queries", type=int, default=10, help="Number of queries to generate.")
parser.add_argument("--insert-ratio", type=float, default=0.5, help="Ratio of insert queries to total queries.")
parser.add_argument("--tables", type=str, required=True, help="Comma-separated list of table names to generate data for.")
parser.add_argument("--output-file", type=str, default=None, help="Output file to write queries.")
args = parser.parse_args()

# Iterate through each table specified
table_names = args.tables.split(",")
queries = []
for table_name in table_names:
    cur.execute(f"SELECT column_name, data_type, column_default, character_maximum_length FROM information_schema.columns WHERE table_name = '{table_name}'")
    schema = cur.fetchall()
    
    is_serial = False
    print(schema)
    if schema[0][2] and 'nextval' in schema[0][2]:
        is_serial = True

    for i in range(args.num_queries):
        if i < args.num_queries * args.insert_ratio:
            # Generate INSERT queries
            values = []
            for column in (schema[1:] if is_serial else schema):
                column_name, data_type, _, max_length = column
                if data_type == 'integer':
                    value = fake.random_int()
                elif data_type == 'numeric':
                    value = round(random.uniform(0, 1000), 2)
                elif data_type in ['text', 'character varying']:
                    value = fake.text(max_nb_chars=min(max_length or 50, 50))  # limit length to 50 or the max length defined in schema
                elif data_type == 'timestamp without time zone':
                    value = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
                else:
                    value = None  # unsupported data type
                
                if value is not None:
                    values.append(f"'{value}'" if isinstance(value, str) else value)

            query = f"INSERT INTO {table_name} ({', '.join([column[0] for column in (schema[1:] if is_serial else schema)])}) VALUES ({', '.join(map(str, values))})"
            queries.append(query)
        else:
            # Generate UPDATE queries
            cur.execute(f"SELECT {schema[0][0]} FROM {table_name} ORDER BY RANDOM() LIMIT 1")
            result = cur.fetchone()

            if result:
                pk_value = result[0]
                set_clauses = []
                for column in schema[1:]:
                    column_name, data_type, _, max_length = column
                    if data_type == 'integer':
                        value = fake.random_int()
                    elif data_type == 'numeric':
                        value = round(random.uniform(0, 1000), 2)
                    elif data_type in ['text', 'character varying']:
                        value = fake.text(max_nb_chars=min(max_length or 50, 50))  # limit length to 50 or the max length defined in schema
                    elif data_type == 'timestamp without time zone':
                        value = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
                    else:
                        value = None  # unsupported data type
                    
                    if value is not None:
                        set_clauses.append(f"{column_name} = '{value}'")

                query = f"UPDATE {table_name} SET {', '.join(set_clauses)} WHERE {schema[0][0]} = {pk_value}"
                queries.append(query)
            else:
                print(f"No data in table {table_name} to generate update queries.")

# Write queries to file
if args.output_file:
    with open(args.output_file, 'w') as f:
        f.write("\n".join(queries))

