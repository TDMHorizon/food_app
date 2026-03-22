const db = require('../config/db');

exports.checkout = async (req, res) => {
  const { total_price, items, delivery_address } = req.body;
  if (total_price == null || !Array.isArray(items)) {
    return res.status(400).json({ message: 'total_price and items required' });
  }
  try {
    const r = await db.query(
      `INSERT INTO orders (user_id, total_price, items, status, delivery_address)
       VALUES ($1, $2, $3::jsonb, $4, $5)
       RETURNING id, total_price, status, created_at`,
      [
        req.user.id,
        Number(total_price),
        JSON.stringify(items),
        'processing',
        delivery_address || null,
      ]
    );
    res.status(201).json(r.rows[0]);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.getRestaurants = async (req, res) => {
  try {
    const result = await db.query('SELECT * FROM restaurants');
    res.json(result.rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

exports.getCategories = async (req, res) => {
  try {
    const result = await db.query('SELECT * FROM categories');
    res.json(result.rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

exports.getMenuItems = async (req, res) => {
  try {
    const { restaurantId, category } = req.query;
    let queryText = 'SELECT * FROM menu_items WHERE 1=1';
    let params = [];
    let counter = 1;
    if (restaurantId) {
      queryText += ` AND restaurant_id = \$${counter}`;
      params.push(restaurantId);
      counter++;
    }
    if (category) {
      queryText += ` AND category = \$${counter}`;
      params.push(category);
      counter++;
    }
    const result = await db.query(queryText, params);
    res.json(result.rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

exports.searchFood = async (req, res) => {
  try {
    const { q } = req.query;
    if (!q) return res.json([]);
    const result = await db.query(
      'SELECT * FROM menu_items WHERE LOWER(name) LIKE $1 OR LOWER(category) LIKE $1',
      [`%${q.toLowerCase()}%`]
    );
    res.json(result.rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Lỗi server' });
  }
};
