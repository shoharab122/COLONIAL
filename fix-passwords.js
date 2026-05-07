// fix-passwords.js
require('dotenv').config();
const bcrypt = require('bcrypt');
const pool = require('./db');

async function fixPasswords() {
  try {
    const adminHash = await bcrypt.hash('admin123', 10);
    const customerHash = await bcrypt.hash('customer123', 10);

    // Insert admin – using ON CONFLICT for PostgreSQL
    await pool.query(`
      INSERT INTO users (email, password, name, role)
      VALUES ($1, $2, $3, $4)
      ON CONFLICT (email) DO UPDATE
      SET password = EXCLUDED.password, role = EXCLUDED.role
    `, ['admin@COLONIAL.com', adminHash, 'Admin User', 'admin']);

    // Insert customer
    await pool.query(`
      INSERT INTO users (email, password, name, role)
      VALUES ($1, $2, $3, $4)
      ON CONFLICT (email) DO UPDATE
      SET password = EXCLUDED.password
    `, ['customer@COLONIAL.com', customerHash, 'Test Customer', 'customer']);

    console.log('✅ Admin and customer users created/updated successfully!');
    console.log('Admin: admin@COLONIAL.com / admin123');
    console.log('Customer: customer@COLONIAL.com / customer123');
    process.exit(0);
  } catch (err) {
    console.error('❌ Error:', err.message);
    process.exit(1);
  }
}

fixPasswords();