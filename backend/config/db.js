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
    console.log('Users table initialized with address support');
  } catch (error) {
    console.error('Error creating users table:', error);
  }
};

createTables();

module.exports = {
  query: (text, params) => pool.query(text, params),
};
