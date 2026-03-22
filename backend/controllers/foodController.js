const db = require('../config/db');

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
