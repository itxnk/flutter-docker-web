const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { Pool } = require('pg');

const app = express();
app.use(express.json({ limit: '1mb' }));

const pool = new Pool({
  host: process.env.DB_HOST || 'postgres',
  port: Number(process.env.DB_PORT || 5432),
  database: process.env.DB_NAME || 'footwear',
  user: process.env.DB_USER || 'footwear',
  password: process.env.DB_PASSWORD || 'footwear_dev_password',
});

const JWT_SECRET = process.env.JWT_SECRET || 'change-this-secret-before-production';
const MERCHANT_NUMBER = process.env.MERCHANT_NUMBER || '03420954886';
const WHATSAPP_NUMBER = process.env.WHATSAPP_NUMBER || '923420954886';

app.get('/api/health', async (_, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ status: 'ok', database: 'connected' });
  } catch (_) {
    res.status(503).json({ status: 'error', database: 'unavailable' });
  }
});

app.get('/api/config', (_, res) => {
  res.json({
    whatsappNumber: '03420954886',
    whatsappUrl: `https://wa.me/${WHATSAPP_NUMBER}`,
    jazzcashNumber: MERCHANT_NUMBER,
    easypaisaNumber: MERCHANT_NUMBER,
  });
});

app.get('/api/products', async (_, res) => {
  try {
    const { rows } = await pool.query('SELECT * FROM products ORDER BY id');
    res.json(rows);
  } catch (_) {
    res.status(500).json({ error: 'Could not load products' });
  }
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
  const { items, payment_method = 'cod', shipping_address } = req.body;
  if (!Array.isArray(items) || !items.length || !shipping_address) {
    return res.status(400).json({ error: 'items and shipping_address are required' });
  }
  if (!['cod', 'jazzcash', 'easypaisa'].includes(payment_method)) {
    return res.status(400).json({ error: 'Unsupported payment method' });
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    const ids = items.map((item) => Number(item.product_id));
    const uniqueIds = [...new Set(ids)];
    const result = await client.query(
      'SELECT id,name,price,stock FROM products WHERE id = ANY($1::int[]) FOR UPDATE',
      [uniqueIds]
    );
    const products = new Map(result.rows.map((row) => [row.id, row]));

    let total = 0;
    const normalized = [];

    for (const item of items) {
      const product = products.get(Number(item.product_id));
      const quantity = Number(item.quantity);

      if (!product) throw new Error('Product not found');
      if (!Number.isInteger(quantity) || quantity < 1) throw new Error('Invalid quantity');
      if (quantity > product.stock) throw new Error(product.name + ' has only ' + product.stock + ' left');

      const unitPrice = Number(product.price);
      total += unitPrice * quantity;
      normalized.push({ productId: product.id, quantity, unitPrice });
    }

    const order = await client.query(
      'INSERT INTO orders(user_id,total,payment_method,shipping_address,status) VALUES($1,$2,$3,$4,$5) RETURNING *',
      [req.user.userId, total, payment_method, shipping_address.trim(), 'pending']
    );

    for (const item of normalized) {
      await client.query(
        'INSERT INTO order_items(order_id,product_id,quantity,unit_price) VALUES($1,$2,$3,$4)',
        [order.rows[0].id, item.productId, item.quantity, item.unitPrice]
      );
      await client.query(
        'UPDATE products SET stock = stock - $1 WHERE id = $2',
        [item.quantity, item.productId]
      );
    }

    if (payment_method !== 'cod') {
      await client.query(
        'INSERT INTO payment_transactions(order_id,user_id,method,amount,merchant_number,status) VALUES($1,$2,$3,$4,$5,$6)',
        [order.rows[0].id, req.user.userId, payment_method, total, MERCHANT_NUMBER, 'awaiting_customer_payment']
      );
    }

    await client.query('COMMIT');
    res.status(201).json({
      ...order.rows[0],
      merchant_number: MERCHANT_NUMBER,
      whatsapp: '03420954886',
    });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error(error);
    res.status(400).json({ error: error.message || 'Could not create order' });
  } finally {
    client.release();
  }
});

app.post('/api/payments/create', auth, async (req, res) => {
  const { order_id, method, amount, transaction_reference } = req.body;
  if (!order_id || !amount || !['jazzcash', 'easypaisa', 'cod'].includes(method)) {
    return res.status(400).json({ error: 'order_id, amount and a supported method are required' });
  }
  try {
    const { rows } = await pool.query(
      `INSERT INTO payment_transactions(order_id,user_id,method,amount,merchant_number,transaction_reference,status)
       VALUES($1,$2,$3,$4,$5,$6,$7) RETURNING *`,
      [order_id, req.user.userId, method, amount, MERCHANT_NUMBER, transaction_reference || null, 'pending_verification']
    );
    res.status(201).json({ ...rows[0], message: 'Payment record created. Real gateway verification requires your merchant API credentials.' });
  } catch (_) {
    res.status(500).json({ error: 'Could not create payment transaction' });
  }
});

app.get('/api/payments/history', auth, async (req, res) => {
  const { rows } = await pool.query(
    'SELECT * FROM payment_transactions WHERE user_id=$1 ORDER BY created_at DESC',
    [req.user.userId]
  );
  res.json(rows);
});

app.get('/api/orders/:id', auth, async (req, res) => {
  const order = await pool.query('SELECT * FROM orders WHERE id=$1 AND user_id=$2', [req.params.id, req.user.userId]);
  if (!order.rows[0]) return res.status(404).json({ error: 'Order not found' });
  const items = await pool.query('SELECT oi.*, p.name, p.image FROM order_items oi JOIN products p ON p.id=oi.product_id WHERE oi.order_id=$1', [req.params.id]);
  const payments = await pool.query('SELECT id,method,amount,transaction_reference,status,created_at FROM payment_transactions WHERE order_id=$1 ORDER BY created_at DESC', [req.params.id]);
  res.json({ ...order.rows[0], items: items.rows, payments: payments.rows });
});

const port = Number(process.env.PORT || 3000);
app.listen(port, () => console.log(`Khan Footwear API listening on ${port}`));
