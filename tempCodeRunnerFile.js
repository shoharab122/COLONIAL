// server.js
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const path = require('path');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const cookieParser = require('cookie-parser');
const pool = require('./db');

const app = express();
const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || 'amoura_super_secret_key_change_me';

app.use(cors());
app.use(express.json());
app.use(cookieParser());
app.use(express.static('public'));

// ------------------- AUTH MIDDLEWARE (supports token in header or query param) -------------------
function authenticateToken(req, res, next) {
  // Try header first
  let token = req.headers['authorization']?.split(' ')[1];
  // If not found, try query param (for SSE)
  if (!token && req.query.token) {
    token = req.query.token;
  }
  if (!token) return res.status(401).json({ error: 'Access denied. No token provided.' });
  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ error: 'Invalid or expired token.' });
    req.user = user;
    next();
  });
}

function requireAdmin(req, res, next) {
  if (req.user.role !== 'admin') return res.status(403).json({ error: 'Admin access required' });
  next();
}

// ------------------- REAL-TIME ORDER EVENTS (SSE) -------------------
const orderClients = [];

app.get('/api/admin/order-events', authenticateToken, requireAdmin, (req, res) => {
  res.writeHead(200, {
    'Content-Type': 'text/event-stream',
    'Cache-Control': 'no-cache',
    'Connection': 'keep-alive'
  });
  res.flushHeaders();

  const clientId = Date.now();
  const newClient = { id: clientId, res };
  orderClients.push(newClient);
  console.log(`SSE client connected: ${clientId}`);

  req.on('close', () => {
    const index = orderClients.findIndex(c => c.id === clientId);
    if (index !== -1) orderClients.splice(index, 1);
    console.log(`SSE client disconnected: ${clientId}`);
  });
});

function broadcastNewOrder(order) {
  console.log('Broadcasting new order:', order.order_number);
  orderClients.forEach(client => {
    try {
      client.res.write(`data: ${JSON.stringify(order)}\n\n`);
    } catch (err) {
      console.error('Error broadcasting to client:', err.message);
    }
  });
}

// ------------------- PRODUCTS (public routes) -------------------
app.get('/api/products', async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT *, 
             (price - COALESCE(discount_amount, 0)) as final_price,
             ROUND(((discount_amount / price) * 100), 0) as discount_percent
      FROM products 
      WHERE is_active = 1 
      ORDER BY created_at DESC
    `);
    const products = rows.map(p => ({
      ...p,
      materials: p.materials ? p.materials.split(',') : [],
      colors: p.colors ? p.colors.split(',') : []
    }));
    res.json(products);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/products/search', async (req, res) => {
  const { q = '', category = 'all', sort = 'newest', page = 1, limit = 8 } = req.query;
  let sql = `
    SELECT *, 
           (price - COALESCE(discount_amount, 0)) as final_price,
           ROUND(((discount_amount / price) * 100), 0) as discount_percent
    FROM products 
    WHERE is_active = 1
  `;
  const params = [];
  if (q) { sql += ' AND name LIKE ?'; params.push(`%${q}%`); }
  if (category && category !== 'all') { sql += ' AND category = ?'; params.push(category); }
  if (sort === 'price_asc') sql += ' ORDER BY final_price ASC';
  else if (sort === 'price_desc') sql += ' ORDER BY final_price DESC';
  else sql += ' ORDER BY created_at DESC';
  const offset = (parseInt(page) - 1) * parseInt(limit);
  sql += ' LIMIT ? OFFSET ?';
  params.push(parseInt(limit), offset);
  try {
    const [rows] = await pool.query(sql, params);
    const products = rows.map(p => ({
      ...p,
      materials: p.materials ? p.materials.split(',') : [],
      colors: p.colors ? p.colors.split(',') : []
    }));
    let countSql = 'SELECT COUNT(*) as total FROM products WHERE is_active = 1';
    const countParams = [];
    if (q) { countSql += ' AND name LIKE ?'; countParams.push(`%${q}%`); }
    if (category && category !== 'all') { countSql += ' AND category = ?'; countParams.push(category); }
    const [countRows] = await pool.query(countSql, countParams);
    const total = countRows[0].total;
    res.json({ products, total, page: parseInt(page), limit: parseInt(limit), totalPages: Math.ceil(total / parseInt(limit)) });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/products/:id', async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT *, 
             (price - COALESCE(discount_amount, 0)) as final_price,
             ROUND(((discount_amount / price) * 100), 0) as discount_percent
      FROM products 
      WHERE id = ? AND is_active = 1
    `, [req.params.id]);
    if (rows.length === 0) return res.status(404).json({ error: 'Product not found' });
    const p = rows[0];
    p.materials = p.materials ? p.materials.split(',') : [];
    p.colors = p.colors ? p.colors.split(',') : [];
    res.json(p);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ------------------- ADMIN PRODUCT MANAGEMENT (protected) -------------------
app.post('/api/products', authenticateToken, requireAdmin, async (req, res) => {
  const { name, price, discount_amount, category, image_url, badge, description, materials, colors, care, stock } = req.body;
  try {
    const [result] = await pool.query(
      `INSERT INTO products 
       (name, price, discount_amount, category, image_url, badge, description, materials, colors, care, stock) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [name, price, discount_amount || 0, category, image_url || '/placeholder.jpg', badge || null, description || '',
       (materials || []).join(','), (colors || []).join(','), care || null, stock || 0]
    );
    res.status(201).json({ id: result.insertId, ...req.body });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put('/api/products/:id', authenticateToken, requireAdmin, async (req, res) => {
  const { name, price, discount_amount, category, image_url, badge, description, materials, colors, care, stock, is_active } = req.body;
  try {
    await pool.query(
      `UPDATE products SET 
        name = ?, price = ?, discount_amount = ?, category = ?, image_url = ?,
        badge = ?, description = ?, materials = ?, colors = ?, care = ?, stock = ?, is_active = ?
       WHERE id = ?`,
      [name, price, discount_amount || 0, category, image_url || '/placeholder.jpg', badge || null, description || '',
       (materials || []).join(','), (colors || []).join(','), care || null, stock || 0,
       is_active !== undefined ? is_active : 1, req.params.id]
    );
    res.json({ id: req.params.id, ...req.body });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/api/products/:id', authenticateToken, requireAdmin, async (req, res) => {
  try {
    await pool.query('DELETE FROM products WHERE id = ?', [req.params.id]);
    res.json({ message: 'Product deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/products/:id/variants', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM product_variants WHERE product_id = ?', [req.params.id]);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ------------------- COUPONS (public validation) -------------------
app.post('/api/validate-coupon', async (req, res) => {
  const { code, cartTotal } = req.body;
  try {
    const [rows] = await pool.query(
      `SELECT * FROM coupons 
       WHERE code = ? AND is_active = 1 
       AND (valid_from IS NULL OR valid_from <= CURDATE())
       AND (valid_to IS NULL OR valid_to >= CURDATE())
       AND (usage_limit IS NULL OR used_count < usage_limit)`,
      [code]
    );
    if (rows.length === 0) return res.status(404).json({ error: 'Invalid or expired coupon' });
    const coupon = rows[0];
    if (cartTotal < coupon.min_order_amount) {
      return res.status(400).json({ error: `Minimum order amount BDT ${coupon.min_order_amount} required` });
    }
    let discount = coupon.discount_type === 'percentage' ? (cartTotal * coupon.discount_value) / 100 : coupon.discount_value;
    discount = Math.min(discount, cartTotal);
    res.json({ code: coupon.code, discount, discount_type: coupon.discount_type, discount_value: coupon.discount_value });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ------------------- ORDERS (public, but associates with logged-in user if token provided) -------------------
app.post('/api/orders', async (req, res) => {
  // Check for user from token (optional)
  let userEmail = null;
  const authHeader = req.headers['authorization'];
  if (authHeader) {
    const token = authHeader.split(' ')[1];
    try {
      const decoded = jwt.verify(token, JWT_SECRET);
      userEmail = decoded.email;
    } catch (err) { /* ignore */ }
  }
  const { customer_name, customer_email, customer_phone, shipping_address, total_amount, discount_applied, final_amount, items, coupon_code, notes } = req.body;
  const finalEmail = userEmail || customer_email;
  const order_number = 'AMR-' + Date.now() + '-' + Math.floor(Math.random() * 1000);
  try {
    const [result] = await pool.query(
      `INSERT INTO orders 
       (order_number, customer_name, customer_email, customer_phone, shipping_address, total_amount, discount_applied, final_amount, items, notes) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [order_number, customer_name, finalEmail, customer_phone || null, shipping_address || null, total_amount, discount_applied || 0, final_amount, JSON.stringify(items), notes || null]
    );
    if (coupon_code) await pool.query('UPDATE coupons SET used_count = used_count + 1 WHERE code = ?', [coupon_code]);
    await pool.query(
      `INSERT INTO customers (email, name, phone, total_orders, total_spent) 
       VALUES (?, ?, ?, 1, ?) 
       ON DUPLICATE KEY UPDATE total_orders = total_orders + 1, total_spent = total_spent + ?`,
      [finalEmail, customer_name, customer_phone, final_amount, final_amount]
    );
    for (const item of items) {
      await pool.query('UPDATE products SET stock = stock - ? WHERE id = ?', [item.quantity, item.id]);
    }

    // 🔔 Broadcast the new order to all connected admin clients
    broadcastNewOrder({
      id: result.insertId,
      order_number,
      customer_name,
      customer_email: finalEmail,
      final_amount,
      created_at: new Date().toISOString()
    });

    res.status(201).json({ id: result.insertId, order_number });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ------------------- ADMIN ORDERS & STATS (protected) -------------------
app.get('/api/admin/orders', authenticateToken, requireAdmin, async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM orders ORDER BY created_at DESC');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put('/api/admin/orders/:id/status', authenticateToken, requireAdmin, async (req, res) => {
  const { status } = req.body;
  try {
    await pool.query('UPDATE orders SET order_status = ? WHERE id = ?', [status, req.params.id]);
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/admin/stats', authenticateToken, requireAdmin, async (req, res) => {
  try {
    const [productRows] = await pool.query('SELECT COUNT(*) as totalProducts FROM products WHERE is_active = 1');
    const [orderRows] = await pool.query('SELECT COUNT(*) as totalOrders, COALESCE(SUM(final_amount), 0) as revenue FROM orders WHERE order_status != "cancelled"');
    const [lowStockRows] = await pool.query('SELECT COUNT(*) as lowStock FROM products WHERE stock < 5 AND is_active = 1');
    res.json({
      totalProducts: productRows[0].totalProducts,
      totalOrders: orderRows[0].totalOrders,
      revenue: orderRows[0].revenue,
      lowStock: lowStockRows[0].lowStock
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ------------------- CUSTOMER AUTHENTICATION -------------------
app.post('/api/auth/register', async (req, res) => {
  const { email, password, name } = req.body;
  if (!email || !password) return res.status(400).json({ error: 'Email and password required' });
  try {
    const [existing] = await pool.query('SELECT id FROM users WHERE email = ?', [email]);
    if (existing.length > 0) return res.status(409).json({ error: 'Email already exists' });
    const hashedPassword = await bcrypt.hash(password, 10);
    const [result] = await pool.query('INSERT INTO users (email, password, name, role) VALUES (?, ?, ?, ?)', [email, hashedPassword, name || null, 'customer']);
    const token = jwt.sign({ id: result.insertId, email, role: 'customer' }, JWT_SECRET, { expiresIn: '7d' });
    res.status(201).json({ token, user: { id: result.insertId, email, name: name || null, role: 'customer' } });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/auth/login', async (req, res) => {
  const { email, password } = req.body;
  try {
    const [rows] = await pool.query('SELECT * FROM users WHERE email = ?', [email]);
    if (rows.length === 0) return res.status(401).json({ error: 'Invalid credentials' });
    const user = rows[0];
    const match = await bcrypt.compare(password, user.password);
    if (!match) return res.status(401).json({ error: 'Invalid credentials' });
    const token = jwt.sign({ id: user.id, email: user.email, role: user.role }, JWT_SECRET, { expiresIn: '7d' });
    res.json({ token, user: { id: user.id, email: user.email, name: user.name, role: user.role } });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/auth/me', authenticateToken, async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT id, email, name, role FROM users WHERE id = ?', [req.user.id]);
    if (rows.length === 0) return res.status(404).json({ error: 'User not found' });
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/customer/orders', authenticateToken, async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM orders WHERE customer_email = ? ORDER BY created_at DESC', [req.user.email]);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ------------------- CATCH-ALL (Express 5 syntax) -------------------
app.get('/{*any}', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// ------------------- START SERVER -------------------
app.listen(PORT, () => {
  console.log(`🚀 AMOURA server running on http://localhost:${PORT}`);
  console.log(`📊 Admin panel: http://localhost:${PORT}/admin.html`);
});