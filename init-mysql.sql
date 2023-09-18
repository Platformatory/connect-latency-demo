-- Create "users" table
CREATE TABLE `jdbc-source-users` (
    id INT PRIMARY KEY AUTO_INCREMENT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source_time TIMESTAMP,
    sink_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    username VARCHAR(50),
    email VARCHAR(255),
    age INT
);

-- Create "orders" table
CREATE TABLE `jdbc-source-orders` (
    id INT PRIMARY KEY AUTO_INCREMENT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source_time TIMESTAMP,
    sink_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    user_id INT,
    total_price DECIMAL(10, 2),
    status VARCHAR(50)
);

