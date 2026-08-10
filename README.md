# Marketing CRM

Ứng dụng quản lý tiến độ công việc phòng Marketing — kiến trúc **Backend + Frontend** tách riêng.

**Thông tin đề tài:**
- **Tên đề tài:** Marketing CRM
- **Người phụ trách đề tài:** Nguyễn Trọng Tín (1 người duy nhất)

## Cấu trúc repo

```
crm/
├── backend/   → Node.js + Express + SQLite REST API (port 3000)
└── frontend/  → Flutter app (Material 3, Provider)
```

Frontend kết nối backend qua REST API bằng **IP máy chạy backend, cổng 3000**:
`http://<IP-máy>:3000/api`

## Chạy backend

```bash
cd backend
npm install
npm start
```

- API lắng nghe trên `0.0.0.0:3000` (truy cập từ mọi thiết bị cùng mạng).
- Tự tạo DB SQLite và seed dữ liệu mẫu khi chạy lần đầu.
- Yêu cầu Node.js >= 22.5 (dùng module `node:sqlite`).

## Chạy frontend

```bash
cd frontend
flutter pub get
flutter run
```

- Địa chỉ backend cấu hình tại `frontend/lib/utils/constants.dart` → `AppConfig.apiHost`.
- Đăng nhập bằng email nhân viên mẫu (vd: `tin.nguyen@company.com`), mật khẩu không kiểm tra.

## API endpoints

Xem danh sách đầy đủ trong `frontend/docs/README.md` (mục 9).
