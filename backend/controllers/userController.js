// PHẦN PUSH (backend): logic DB cho Payment Details, My Orders, Notifications, Inbox (theo user_id từ JWT)
const db = require('../config/db');

exports.getCards = async (req, res) => {
  try {
    const r = await db.query(
      'SELECT id, brand, last4, created_at FROM user_cards WHERE user_id = $1 ORDER BY id ASC',
      [req.user.id]
    );
    res.json(r.rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.addCard = async (req, res) => {
  const { brand, last4 } = req.body;
  if (!brand || !last4) {
    return res.status(400).json({ message: 'brand and last4 required' });
  }
  try {
    const r = await db.query(
      'INSERT INTO user_cards (user_id, brand, last4) VALUES ($1, $2, $3) RETURNING id, brand, last4, created_at',
      [req.user.id, String(brand).slice(0, 20), String(last4).slice(0, 4)]
    );
    res.status(201).json(r.rows[0]);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.deleteCard = async (req, res) => {
  const { id } = req.params;
  try {
    const r = await db.query(
      'DELETE FROM user_cards WHERE id = $1 AND user_id = $2 RETURNING id',
      [id, req.user.id]
    );
    if (r.rowCount === 0) return res.status(404).json({ message: 'Not found' });
    res.json({ ok: true });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.getOrders = async (req, res) => {
  try {
    const r = await db.query(
      'SELECT id, total_price, items, status, delivery_address, created_at FROM orders WHERE user_id = $1 ORDER BY created_at DESC',
      [req.user.id]
    );
    res.json(r.rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.getNotifications = async (req, res) => {
  try {
    const r = await db.query(
      'SELECT id, title, body, is_read, created_at FROM notifications WHERE user_id = $1 ORDER BY created_at DESC',
      [req.user.id]
    );
    res.json(r.rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.getUnreadNotificationCount = async (req, res) => {
  try {
    const r = await db.query(
      'SELECT COUNT(*)::int AS c FROM notifications WHERE user_id = $1 AND is_read = false',
      [req.user.id]
    );
    res.json({ count: r.rows[0].c });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.getInbox = async (req, res) => {
  try {
    const r = await db.query(
      'SELECT id, title, preview, body, is_read, is_starred, created_at FROM inbox_messages WHERE user_id = $1 ORDER BY created_at DESC',
      [req.user.id]
    );
    res.json(r.rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: 'Server error' });
  }
};
