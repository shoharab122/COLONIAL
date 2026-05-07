require('dotenv').config();
const bcrypt = require('bcrypt');
const pool = require('./db');

async function createCustomer() {
  const email = 'customer@amoura.com';
  const password = 'customer123';
  const name = 'Test Customer';
  const hashedPassword = await bcrypt.hash(password, 10);
  try {
    await pool.query(
      'INSERT INTO users (email, password, name, role) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE email=email',
      [email, hashedPassword, name, 'customer']
    );
    console.log('Test customer created');
    process.exit();
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
}
createCustomer();