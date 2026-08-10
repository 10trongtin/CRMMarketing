const express = require('express');
const db = require('../db');

const router = express.Router();

function count(where, params) {
  const row = db.prepare(`SELECT COUNT(*) AS c FROM tasks ${where}`).get(...params);
  return row.c;
}

router.get('/dashboard', (req, res) => {
  const employeeId = req.query.employeeId ? Number(req.query.employeeId) : null;
  const assignee = (sql) =>
    employeeId != null ? `${sql} AND assignee_id = ?` : sql;
  const params = employeeId != null ? [employeeId] : [];

  res.json({
    total: count('', []),
    todo: count(assignee(`WHERE status = 'todo'`), params),
    in_progress: count(assignee(`WHERE status = 'in_progress'`), params),
    review: count(assignee(`WHERE status = 'review'`), params),
    done: count(assignee(`WHERE status = 'done'`), params),
    overdue: count(
      assignee(`WHERE status != 'done' AND due_date < ?`),
      employeeId != null ? [new Date().toISOString(), employeeId] : [new Date().toISOString()]
    ),
  });
});

router.get('/employees-completion', (req, res) => {
  const rows = db
    .prepare(
      `SELECT e.id, e.name,
              COUNT(t.id) AS total,
              SUM(CASE WHEN t.status = 'done' THEN 1 ELSE 0 END) AS completed
       FROM employees e
       LEFT JOIN tasks t ON e.id = t.assignee_id
       GROUP BY e.id`
    )
    .all();

  const stats = {};
  for (const row of rows) {
    const total = row.total || 0;
    const completed = row.completed || 0;
    stats[row.name] = total > 0 ? (completed / total) * 100 : 0;
  }
  res.json(stats);
});

router.get('/priority', (req, res) => {
  const rows = db
    .prepare('SELECT priority, COUNT(*) AS count FROM tasks GROUP BY priority')
    .all();
  const stats = {};
  for (const row of rows) stats[row.priority] = row.count;
  res.json(stats);
});

module.exports = router;
