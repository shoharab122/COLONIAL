const bcrypt = require('bcrypt');
const pool = require('./db');

async function updateAdmin() {
  try {
    const hash = await bcrypt.hash('admin123', 10);
    await pool.query('UPDATE users SET password = $1 WHERE email = $2', [hash, 'admin@COLONIAL.com']);
    console.log('✅ Admin password updated successfully to: admin123');
    process.exit(0);
  } catch (err) {
    console.error('Error:', err.message);
    process.exit(1);
  }
}

updateAdmin();
