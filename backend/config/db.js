require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
  user: process.env.DB_USER || 'postgres',
  host: process.env.DB_HOST || 'localhost',
  database: process.env.DB_NAME || 'appfood_db',
  password: process.env.DB_PASSWORD || 'password',
  port: process.env.DB_PORT || 5432,
});

pool.on('connect', () => {
  console.log('Connected to PostgreSQL Database');
});

// Create tables if they don't exist
const createTables = async () => {
  const queryText = `
    CREATE TABLE IF NOT EXISTS users (
      id SERIAL PRIMARY KEY,
      fullname VARCHAR(100) NOT NULL,
      email VARCHAR(100) UNIQUE NOT NULL,
      password VARCHAR(255) NOT NULL,
      phone VARCHAR(20),
      address VARCHAR(255),
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  `;
  try {
    await pool.query(queryText);
    await pool.query('ALTER TABLE users ADD COLUMN IF NOT EXISTS address VARCHAR(255);');
    
    // Create Food tables
    const foodTablesText = `
      CREATE TABLE IF NOT EXISTS restaurants (
        id VARCHAR(50) PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        rating VARCHAR(10),
        review_count VARCHAR(50),
        type1 VARCHAR(100),
        type2 VARCHAR(100),
        image TEXT,
        distance_km DOUBLE PRECISION
      );

      CREATE TABLE IF NOT EXISTS categories (
        id VARCHAR(50) PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        image TEXT,
        items_count VARCHAR(50)
      );

      CREATE TABLE IF NOT EXISTS menu_items (
        id VARCHAR(50) PRIMARY KEY,
        restaurant_id VARCHAR(50) REFERENCES restaurants(id) ON DELETE CASCADE,
        name VARCHAR(255) NOT NULL,
        description TEXT,
        price DOUBLE PRECISION,
        category VARCHAR(100),
        emoji VARCHAR(10),
        is_best_seller BOOLEAN DEFAULT FALSE
      );
    `;
    await pool.query(foodTablesText);
    
    console.log('All Database tables initialized successfully');

    // Run seed data
    try {
      require('./seed').seedData(pool);
    } catch(err) {
      console.log('Seed file not fully ready or error:', err.message);
    }
  } catch (error) {
    console.error('Error creating users table:', error);
  }
};

createTables();

module.exports = {
  query: (text, params) => pool.query(text, params),
};
