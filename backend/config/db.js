const path = require('path');
// quiet: tránh log dotenv trùng khi server.js đã load .env trước
require('dotenv').config({ path: path.join(__dirname, '..', '.env'), quiet: true });

const { Pool } = require('pg');

const dbPort = Number.parseInt(process.env.DB_PORT || '5432', 10);
const pool = new Pool({
  user: process.env.DB_USER || 'postgres',
  host: process.env.DB_HOST || '127.0.0.1',
  database: process.env.DB_NAME || 'appfood_db',
  password: process.env.DB_PASSWORD || 'password',
  port: Number.isFinite(dbPort) && dbPort > 0 ? dbPort : 5432,
});

pool.on('connect', () => {
  console.log('Connected to PostgreSQL Database');
});

const dbHost = process.env.DB_HOST || '127.0.0.1';
const dbName = process.env.DB_NAME || 'appfood_db';
console.log(`[DB] Thử kết nối: ${dbHost}:${pool.options.port} / database "${dbName}" (user: ${pool.options.user})`);

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

    // bảng phục vụ tab Khác + Payment (thẻ, đơn, thông báo, inbox)
    const extraTables = `
      CREATE TABLE IF NOT EXISTS user_cards (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        brand VARCHAR(20) NOT NULL,
        last4 VARCHAR(4) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );

      CREATE TABLE IF NOT EXISTS orders (
        id SERIAL PRIMARY KEY,
        user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
        total_price DOUBLE PRECISION NOT NULL,
        items JSONB NOT NULL,
        status VARCHAR(50) DEFAULT 'processing',
        delivery_address TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );

      CREATE TABLE IF NOT EXISTS notifications (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        title VARCHAR(255) NOT NULL,
        body TEXT,
        is_read BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );

      CREATE TABLE IF NOT EXISTS inbox_messages (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        title VARCHAR(255) NOT NULL,
        preview TEXT,
        body TEXT,
        is_read BOOLEAN DEFAULT FALSE,
        is_starred BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `;
    await pool.query(extraTables);

    console.log('All Database tables initialized successfully');

    // Run seed data
    try {
      require('./seed').seedData(pool);
    } catch(err) {
      console.log('Seed file not fully ready or error:', err.message);
    }
  } catch (error) {
    const host = process.env.DB_HOST || '127.0.0.1';
    const port = Number.parseInt(process.env.DB_PORT || '5432', 10) || 5432;
    console.error('Error connecting to PostgreSQL / creating tables:', error.message || error);
    if (error.code === 'ECONNREFUSED') {
      console.error(
        `→ Không kết nối được ${host}:${port}. Kiểm tra: (1) dịch vụ PostgreSQL đang Running, (2) đúng cổng trong pgAdmin → Properties → Connection, (3) DB_PORT trong file backend/.env`
      );
    }
    if (error.code === '28P01' || error.message?.includes('password')) {
      console.error('→ Sai mật khẩu hoặc user: chỉnh DB_USER / DB_PASSWORD trong backend/.env');
    }
    if (error.code === '3D000') {
      console.error(
        '→ Database chưa tồn tại: tạo trong pgAdmin hoặc chạy CREATE DATABASE appfood_db; (hoặc đổi DB_NAME trong .env)'
      );
    }
  }
};

createTables();

module.exports = {
  query: (text, params) => pool.query(text, params),
};
