const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { Pool } = require('pg');

const app = express();
app.use(express.json());

const pool = new Pool({
  host: process.env.DB_HOST || 'postgres',
  port: Number(process.env.DB_PORT || 5432),
  database: process.env.DB_NAME || 'footwear',
  user: process.env.DB_USER || 'footwear',
  password: process.env.DB_PASSWORD || 'footwear_dev_password',
});

const JWT_SECRET = process.env.JWT_SECRET || 'change-this-secret-before-production';

app.get('/api/health', async (_, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ status: 'ok', database: 'connected' });
  } catch (error) {
    res.status(503).json({ status: 'error', database: 'unavailable' });
  }
});

app.get('/api/products', async (_, res) => {
  const { rows } = await pool.query('SELECT * FROM products ORDER BY id');
  res.json(rows);
});

app.post('/api/auth/register', async (req, res) => {
  const { name, email, phone, password } = req.body;
  if (!name || !email || !password) return res.status(400).json({ error: 'name, email and password are required' });
  const hash = await bcrypt.hash(password, 12);
  try {
    const { rows } = await pool.query(
      'INSERT INTO users(name,email,phone,password_hash) VALUES($1,$2,$3,$4) RETURNING id,name,email,phone',
      [name, email.toLowerCase(), phone || null, hash]
    );
    res.status(201).json(rows[0]);
  } catch (error) {
    if (error.code === '23505') return res.status(409).json({ error: 'Email already registered' });
    res.status(500).json({ error: 'Registration failed' });
  }
});

app.post('/api/auth/login', async (req, res) => {
  const { email, password } = req.body;
  const { rows } = await pool.query('SELECT * FROM users WHERE email=$1', [(email || '').toLowerCase()]);
  const user = rows[0];
  if (!user || !(await bcrypt.compare(password || '', user.password_hash))) {
    return res.status(401).json({ error: 'Invalid email or password' });
  }
  const token = jwt.sign({ userId: user.id, email: user.email }, JWT_SECRET, { expiresIn: '7d' });
  res.json({ token, user: { id: user.id, name: user.name, email: user.email, phone: user.phone } });
});

function auth(req, res, next) {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) return res.status(401).json({ error: 'Authentication required' });
  try {
    req.user = jwt.verify(token, JWT_SECRET);
    next();
  } catch (_) {
    res.status(401).json({ error: 'Invalid or expired token' });
  }
}

app.get('/api/me', auth, async (req, res) => {
  const { rows } = await pool.query('SELECT id,name,email,phone,created_at FROM users WHERE id=$1', [req.user.userId]);
  res.json(rows[0]);
});

app.get('/api/orders', auth, async (req, res) => {
  const { rows } = await pool.query('SELECT * FROM orders WHERE user_id=$1 ORDER BY created_at DESC', [req.user.userId]);
  res.json(rows);
});

app.post('/api/orders', auth, async (req, res) => {
  const { items, total, payment_method = 'cod', shipping_address } = req.body;
  if (!Array.isArray(items) || !items.length || !total || !shipping_address) {
    return res.status(400).json({ error: 'items, total and shipping_address are required' });
  }
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const order = await client.query(
      'INSERT INTO orders(user_id,total,payment_method,shipping_address,status) VALUES($1,$2,$3,$4,$5) RETURNING *',
      [req.user.userId, total, payment_method, shipping_address, 'pending']
    );
    for (const item of items) {
      await client.query(
        'INSERT INTO order_items(order_id,product_id,quantity,unit_price) VALUES($1,$2,$3,$4)',
        [order.rows[0].id, item.product_id, item.quantity, item.unit_price]
      );
    }
    await client.query('COMMIT');
    res.status(201).json(order.rows[0]);
  } catch (error) {
    await client.query('ROLLBACK');
    res.status(500).json({ error: 'Could not create order' });
  } finally {
    client.release();
  }
});

app.post('/api/payments/create', auth, (req, res) => {
  const { method } = req.body;
  if (!['jazzcash', 'easypaisa', 'cod'].includes(method)) return res.status(400).json({ error: 'Unsupported payment method' });
  res.json({
    status: 'sandbox_pending',
    method,
    message: 'Payment gateway credentials are not configured yet. Connect merchant sandbox credentials before accepting real payments.'
  });
});

const port = Number(process.env.PORT || 3000);
app.listen(port, () => console.log(`Khan Footwear API listening on ${port}`));
