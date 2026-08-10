const express = require('express');
const db = require('../db');

const router = express.Router();

router.post('/login', (req, res) => {
  const { email, password } = req.body || {};
  if (!email || typeof email !== 'string') {
    return res.status(400).json({ error: 'Email là bắt buộc' });
  }

  const employee = db
    .prepare('SELECT * FROM employees WHERE LOWER(email) = LOWER(?)')
    .get(email);

  if (!employee) {
    return res.status(401).json({ error: 'Email hoặc mật khẩu không đúng' });
  }

  res.json(employee);
});

router.post('/logout', (req, res) => {
  res.json({ success: true });
});

module.exports = router;
