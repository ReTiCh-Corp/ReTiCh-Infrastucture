-- PostgreSQL initialization script for ReTiCh
-- This script creates multiple databases for each microservice

-- Create databases
CREATE DATABASE retich_auth;
CREATE DATABASE retich_users;
CREATE DATABASE retich_messaging;

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE retich_auth TO retich;
GRANT ALL PRIVILEGES ON DATABASE retich_users TO retich;
GRANT ALL PRIVILEGES ON DATABASE retich_messaging TO retich;

-- Connect to auth database and create schema
\c retich_auth
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Connect to users database and create schema
\c retich_users
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Connect to messaging database and create schema
\c retich_messaging
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
