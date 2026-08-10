const express = require('express');
const db = require('../db');

const router = express.Router();

const TASK_SELECT = `
  SELECT t.*,
         e.name AS assignee_name, e.email AS assignee_email, e.position AS assignee_position,
         p.name AS project_name, p.status AS project_status
  FROM tasks t
  LEFT JOIN employees e ON t.assignee_id = e.id
  LEFT JOIN projects p ON t.project_id = p.id
`;

router.get('/', (req, res) => {
  const { status, assigneeId, projectId, search } = req.query;
  const conditions = [];
  const params = [];

  if (status && status !== 'all') {
    conditions.push('t.status = ?');
    params.push(status);
  }
  if (assigneeId) {
    conditions.push('t.assignee_id = ?');
    params.push(Number(assigneeId));
  }
  if (projectId) {
    conditions.push('t.project_id = ?');
    params.push(Number(projectId));
  }
  if (search && search.trim() !== '') {
    conditions.push('(t.title LIKE ? OR t.description LIKE ?)');
    params.push(`%${search}%`, `%${search}%`);
  }

  let sql = TASK_SELECT;
  if (conditions.length > 0) {
    sql += ` WHERE ${conditions.join(' AND ')}`;
  }
  sql += ' ORDER BY t.due_date ASC, t.priority DESC';

  const rows = db.prepare(sql).all(...params);
  res.json(rows);
});

router.get('/:id', (req, res) => {
  const row = db.prepare(`${TASK_SELECT} WHERE t.id = ?`).get(req.params.id);
  if (!row) return res.status(404).json({ error: 'Không tìm thấy công việc' });
  res.json(row);
});

router.post('/', (req, res) => {
  const {
    title,
    description = '',
    project_id = null,
    assignee_id = null,
    status = 'todo',
    priority = 'medium',
    start_date = null,
    due_date = null,
    completed_at = null,
    progress = 0,
  } = req.body || {};
  if (!title) return res.status(400).json({ error: 'title là bắt buộc' });

  const now = new Date().toISOString();
  const info = db
    .prepare(
      `INSERT INTO tasks (title, description, project_id, assignee_id, status, priority,
                          start_date, due_date, completed_at, progress, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`
    )
    .run(title, description, project_id, assignee_id, status, priority,
         start_date, due_date, completed_at, progress, now, now);
  const row = db.prepare(`${TASK_SELECT} WHERE t.id = ?`).get(info.lastInsertRowid);
  res.status(201).json(row);
});

router.put('/:id', (req, res) => {
  const existing = db.prepare('SELECT * FROM tasks WHERE id = ?').get(req.params.id);
  if (!existing) return res.status(404).json({ error: 'Không tìm thấy công việc' });

  const {
    title, description, project_id, assignee_id, status, priority,
    start_date, due_date, completed_at, progress,
  } = req.body || {};
  const updatedAt = new Date().toISOString();

  db.prepare(
    `UPDATE tasks SET title = ?, description = ?, project_id = ?, assignee_id = ?, status = ?,
                      priority = ?, start_date = ?, due_date = ?, completed_at = ?, progress = ?,
                      updated_at = ?
     WHERE id = ?`
  ).run(
    title ?? existing.title,
    description ?? existing.description,
    project_id === undefined ? existing.project_id : project_id,
    assignee_id === undefined ? existing.assignee_id : assignee_id,
    status ?? existing.status,
    priority ?? existing.priority,
    start_date === undefined ? existing.start_date : start_date,
    due_date === undefined ? existing.due_date : due_date,
    completed_at === undefined ? existing.completed_at : completed_at,
    progress ?? existing.progress,
    updatedAt,
    existing.id
  );
  const row = db.prepare(`${TASK_SELECT} WHERE t.id = ?`).get(existing.id);
  res.json(row);
});

router.delete('/:id', (req, res) => {
  const info = db.prepare('DELETE FROM tasks WHERE id = ?').run(req.params.id);
  if (info.changes === 0) return res.status(404).json({ error: 'Không tìm thấy công việc' });
  res.status(204).end();
});

module.exports = router;
