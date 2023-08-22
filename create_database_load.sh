docker-compose exec pgloader python3 /app/gen_queries.py --tables users,orders --num-queries 500 --insert-ratio 0.6 --output-file /app/queries.txt
docker-compose exec pgloader python3 /app/exec_queries.py --query-file /app/queries.txt --num-loops 5 --sleep-interval 0.1

