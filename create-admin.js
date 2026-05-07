require('dotenv').config();
const bcrypt = require('bcrypt');
const pool = require('./db');

async function createAdmin() {
  const email = 'admin@amoura.com';
  const password = 'admin123';
  const name = 'Admin User';
  const hashedPassword = await bcrypt.hash(password, 10);
  try {
    await pool.query(
      'INSERT INTO users (email, password, name, role) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE email=email',
      [email, hashedPassword, name, 'admin']
    );
    console.log('Admin user created (or already exists)');
    process.exit();
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
}
createAdmin();