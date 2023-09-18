-- Create "users" table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    username VARCHAR(50),
    email VARCHAR(255),
    age INT
);

-- Create "orders" table
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_id INT,
    total_price DECIMAL(10, 2),
    status VARCHAR(50)
);


