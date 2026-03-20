const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const db = require('../config/db');

// @route   POST /api/auth/register
// @desc    Register a user
const register = async (req, res) => {
  const { fullname, email, password, phone, address } = req.body;

  try {
    // 1. Check if user exists
    const userCheck = await db.query('SELECT * FROM users WHERE email = $1', [email]);
    if (userCheck.rows.length > 0) {
      return res.status(400).json({ message: 'User already exists' });
    }

    // 2. Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // 3. Insert user into db
    const newUser = await db.query(
      'INSERT INTO users (fullname, email, password, phone, address) VALUES ($1, $2, $3, $4, $5) RETURNING id, fullname, email, phone, address',
      [fullname, email, hashedPassword, phone, address]
    );

    // 4. Create and return JWT
    const payload = {
      user: {
        id: newUser.rows[0].id,
      },
    };

    jwt.sign(
      payload,
      process.env.JWT_SECRET || 'secret_key_appfood_2024',
      { expiresIn: '30d' },
      (err, token) => {
        if (err) throw err;
        res.status(201).json({ token, user: newUser.rows[0] });
      }
    );
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// @route   POST /api/auth/login
// @desc    Authenticate user & get token
const login = async (req, res) => {
  const { email, password } = req.body;

  try {
    // 1. Check if user exists
    const userResult = await db.query('SELECT * FROM users WHERE email = $1', [email]);
    if (userResult.rows.length === 0) {
      return res.status(400).json({ message: 'Invalid Credentials' });
    }

    const user = userResult.rows[0];

    // 2. Check password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Invalid Credentials' });
    }

    // 3. Return JWT
    const payload = {
      user: {
        id: user.id,
      },
    };

    jwt.sign(
      payload,
      process.env.JWT_SECRET || 'secret_key_appfood_2024',
      { expiresIn: '30d' },
      (err, token) => {
        if (err) throw err;
        const userWithoutPassword = { ...user };
        delete userWithoutPassword.password;
        res.json({ token, user: userWithoutPassword });
      }
    );
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// @route   GET /api/auth/profile
// @desc    Get user profile
const getProfile = async (req, res) => {
  try {
    const userResult = await db.query(
      'SELECT id, fullname, email, phone, address, created_at FROM users WHERE id = $1',
      [req.user.id]
    );
    
    if (userResult.rows.length === 0) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    res.json(userResult.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// @route   POST /api/auth/social
// @desc    Social Login (Google/Facebook)
const socialLogin = async (req, res) => {
  const { email, fullname, provider, provider_id } = req.body;

  try {
    // 1. Check if user already exists
    let userResult = await db.query('SELECT * FROM users WHERE email = $1', [email]);
    let user;

    if (userResult.rows.length > 0) {
      user = userResult.rows[0];
    } else {
      // 2. If not exists, register a new user automatically
      const generatedPassword = await bcrypt.hash(provider_id || Math.random().toString(36), 10);
      const newUser = await db.query(
        'INSERT INTO users (fullname, email, password) VALUES ($1, $2, $3) RETURNING id, fullname, email',
        [fullname || 'Social User', email, generatedPassword]
      );
      user = newUser.rows[0];
    }

    // 3. Create and return JWT
    const payload = {
      user: { id: user.id },
    };

    jwt.sign(
      payload,
      process.env.JWT_SECRET || 'super_secret_jwt_key_for_appfood_2024',
      { expiresIn: '5h' },
      (err, token) => {
        if (err) throw err;
        res.json({ token, user });
      }
    );
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

module.exports = {
  register,
  login,
  getProfile,
  socialLogin,
};
