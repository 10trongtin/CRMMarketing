const express = require('express');
const db = require('../db');

const router = express.Router();

router.get('/', (req, res) => {
  const rows = db
    .prepare('SELECT * FROM projects ORDER BY created_at DESC')
    .all();
  res.json(rows);
});

router.get('/:id', (req, res) => {
  const row = db.prepare('SELECT * FROM projects WHERE id = ?').get(req.params.id);
  if (!row) return res.status(404).json({ error: 'Không tìm thấy dự án' });
  res.json(row);
});

router.post('/', (req, res) => {
  const {
    name,
    description = '',
    start_date = null,
    end_date = null,
    status = 'active',
  } = req.body || {};
  if (!name) return res.status(400).json({ error: 'name là bắt buộc' });

  const createdAt = new Date().toISOString();
  const info = db
    .prepare(
      'INSERT INTO projects (name, description, start_date, end_date, status, created_at) VALUES (?, ?, ?, ?, ?, ?)'
    )
    .run(name, description, start_date, end_date, status, createdAt);
  const row = db.prepare('SELECT * FROM projects WHERE id = ?').get(info.lastInsertRowid);
  res.status(201).json(row);
});

router.put('/:id', (req, res) => {
  const existing = db.prepare('SELECT * FROM projects WHERE id = ?').get(req.params.id);
  if (!existing) return res.status(404).json({ error: 'Không tìm thấy dự án' });

  const { name, description, start_date, end_date, status } = req.body || {};
  db.prepare(
    `UPDATE projects SET name = ?, description = ?, start_date = ?, end_date = ?, status = ? WHERE id = ?`
  ).run(
    name ?? existing.name,
    description ?? existing.description,
    start_date === undefined ? existing.start_date : start_date,
    end_date === undefined ? existing.end_date : end_date,
    status ?? existing.status,
    existing.id
  );
  const row = db.prepare('SELECT * FROM projects WHERE id = ?').get(existing.id);
  res.json(row);
});

router.delete('/:id', (req, res) => {
  const info = db.prepare('DELETE FROM projects WHERE id = ?').run(req.params.id);
  if (info.changes === 0) return res.status(404).json({ error: 'Không tìm thấy dự án' });
  res.status(204).end();
});

module.exports = router;
