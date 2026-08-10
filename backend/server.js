const express = require('express');
const cors = require('cors');
const routes = require('./src/routes');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    console.log(
      `[${new Date().toISOString()}] ${req.method} ${req.originalUrl} -> ${res.statusCode} (${Date.now() - start}ms)`
    );
  });
  next();
});

app.get('/', (req, res) => {
  res.json({ name: 'Marketing CRM API', status: 'ok', endpoints: '/api/...' });
});

app.use('/api', routes);

app.use((req, res) => {
  res.status(404).json({ error: 'Không tìm thấy endpoint' });
});

app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: 'Lỗi server' });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Marketing CRM API đang chạy tại http://0.0.0.0:${PORT}`);
  console.log(`Truy cập từ thiết bị khác: http://<IP-máy>:${PORT}/api`);
});
