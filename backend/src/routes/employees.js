const express = require('express');
const db = require('../db');

const router = express.Router();

router.get('/', (req, res) => {
  const rows = db
    .prepare('SELECT * FROM employees ORDER BY name ASC')
    .all();
  res.json(rows);
});

router.get('/:id', (req, res) => {
  const row = db.prepare('SELECT * FROM employees WHERE id = ?').get(req.params.id);
  if (!row) return res.status(404).json({ error: 'Không tìm thấy nhân viên' });
  res.json(row);
});

router.post('/', (req, res) => {
  const { name, email, phone = '', position = '', avatar = null } = req.body || {};
  if (!name || !email) {
    return res.status(400).json({ error: 'name và email là bắt buộc' });
  }
  const createdAt = new Date().toISOString();
  const info = db
    .prepare('INSERT INTO employees (name, email, phone, position, avatar, created_at) VALUES (?, ?, ?, ?, ?, ?)')
    .run(name, email, phone, position, avatar, createdAt);
  const row = db.prepare('SELECT * FROM employees WHERE id = ?').get(info.lastInsertRowid);
  res.status(201).json(row);
});

router.put('/:id', (req, res) => {
  const existing = db.prepare('SELECT * FROM employees WHERE id = ?').get(req.params.id);
  if (!existing) return res.status(404).json({ error: 'Không tìm thấy nhân viên' });

  const { name, email, phone, position, avatar } = req.body || {};
  db.prepare(
    `UPDATE employees SET name = ?, email = ?, phone = ?, position = ?, avatar = ? WHERE id = ?`
  ).run(
    name ?? existing.name,
    email ?? existing.email,
    phone ?? existing.phone,
    position ?? existing.position,
    avatar === undefined ? existing.avatar : avatar,
    existing.id
  );
  const row = db.prepare('SELECT * FROM employees WHERE id = ?').get(existing.id);
  res.json(row);
});

router.delete('/:id', (req, res) => {
  const info = db.prepare('DELETE FROM employees WHERE id = ?').run(req.params.id);
  if (info.changes === 0) return res.status(404).json({ error: 'Không tìm thấy nhân viên' });
  res.status(204).end();
});

module.exports = router;
