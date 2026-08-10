const express = require('express');

const authRouter = require('./auth');
const employeesRouter = require('./employees');
const projectsRouter = require('./projects');
const tasksRouter = require('./tasks');
const statsRouter = require('./stats');

const router = express.Router();

router.use('/auth', authRouter);
router.use('/employees', employeesRouter);
router.use('/projects', projectsRouter);
router.use('/tasks', tasksRouter);
router.use('/stats', statsRouter);

module.exports = router;
