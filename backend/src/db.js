const { DatabaseSync } = require('node:sqlite');
const path = require('path');

const DB_PATH =
  process.env.DB_PATH || path.join(__dirname, '..', 'crm_marketing.db');

const db = new DatabaseSync(DB_PATH);

db.exec(`
  PRAGMA journal_mode = WAL;

  CREATE TABLE IF NOT EXISTS employees (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT DEFAULT '',
    position TEXT DEFAULT '',
    avatar TEXT,
    created_at TEXT NOT NULL
  );

  CREATE TABLE IF NOT EXISTS projects (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT DEFAULT '',
    start_date TEXT,
    end_date TEXT,
    status TEXT DEFAULT 'active',
    created_at TEXT NOT NULL
  );

  CREATE TABLE IF NOT EXISTS tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT DEFAULT '',
    project_id INTEGER,
    assignee_id INTEGER,
    status TEXT DEFAULT 'todo',
    priority TEXT DEFAULT 'medium',
    start_date TEXT,
    due_date TEXT,
    completed_at TEXT,
    progress INTEGER DEFAULT 0,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE SET NULL,
    FOREIGN KEY (assignee_id) REFERENCES employees(id) ON DELETE SET NULL
  );
`);

function seed() {
  const count = db.prepare('SELECT COUNT(*) AS c FROM employees').get().c;
  if (count > 0) return;

  const now = new Date().toISOString();
  const insertEmployee = db.prepare(
    `INSERT INTO employees (name, email, phone, position, created_at)
     VALUES (?, ?, ?, ?, ?)`
  );
  const employees = [
    ['Nguyễn Minh Tuấn', 'tuan.nguyen@company.com', '0901234567', 'Trưởng phòng Marketing'],
    ['Trần Thị Bình', 'binh.tran@company.com', '0901234568', 'Chuyên viên Content'],
    ['Lê Hoàng Cường', 'cuong.le@company.com', '0901234569', 'Chuyên viên SEO'],
    ['Phạm Minh Dung', 'dung.pham@company.com', '0901234570', 'Designer'],
    ['Hoàng Thị Em', 'em.hoang@company.com', '0901234571', 'Chuyên viên Social Media'],
  ];
  for (const e of employees) {
    insertEmployee.run(...e, now);
  }

  const insertProject = db.prepare(
    `INSERT INTO projects (name, description, start_date, end_date, status, created_at)
     VALUES (?, ?, ?, ?, ?, ?)`
  );
  insertProject.run('Chiến dịch Quảng cáo Q3', 'Chiến dịch quảng cáo đa kênh cho quý 3 năm 2026', '2026-07-01', '2026-09-30', 'active', now);
  insertProject.run('Tái thiết Website', 'Dự án thiết kế lại website công ty', '2026-06-01', '2026-08-31', 'active', now);
  insertProject.run('Chiến dịch Email Marketing', 'Chiến dịch email marketing khách hàng thân thiết', '2026-07-15', '2026-08-15', 'active', now);

  const insertTask = db.prepare(
    `INSERT INTO tasks (title, description, project_id, assignee_id, status, priority,
                        start_date, due_date, completed_at, progress, created_at, updated_at)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`
  );
  const tasks = [
    ['Thiết kế banner quảng cáo', 'Thiết kế banner cho chiến dịch Facebook Ads', 1, 4, 'in_progress', 'high', '2026-07-01', '2026-07-15', null, 60],
    ['Viết content bài đăng blog', 'Viết 5 bài blog về sản phẩm mới', 2, 2, 'todo', 'medium', '2026-07-10', '2026-07-25', null, 0],
    ['Nghiên cứu từ khóa SEO', 'Nghiên cứu và phân tích từ khóa cho website mới', 2, 3, 'done', 'high', '2026-06-01', '2026-06-15', '2026-06-14', 100],
    ['Xây dựng kịch bản video TikTok', 'Xây dựng kịch bản cho 10 video TikTok ngắn', 1, 5, 'review', 'medium', '2026-07-05', '2026-07-20', null, 85],
    ['Tạo email template', 'Thiết kế template cho chiến dịch email marketing', 3, 4, 'todo', 'urgent', '2026-07-15', '2026-07-18', null, 0],
    ['Phân tích đối thủ cạnh tranh', 'Phân tích chiến lược marketing của 3 đối thủ chính', 1, 1, 'in_progress', 'high', '2026-07-08', '2026-07-22', null, 35],
    ['Báo cáo KPI tháng 7', 'Tổng hợp và báo cáo KPI marketing tháng 7', 1, 1, 'todo', 'low', '2026-07-25', '2026-07-31', null, 0],
  ];
  for (const [title, description, projectId, assigneeId, status, priority, startDate, dueDate, completedAt, progress] of tasks) {
    insertTask.run(title, description, projectId, assigneeId, status, priority, startDate, dueDate, completedAt, progress, now, now);
  }

  console.log('Seeded sample data.');
}

seed();

module.exports = db;
