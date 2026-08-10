# Marketing CRM — Ứng dụng Quản lý Tiến độ Công việc Phòng Marketing

Ứng dụng quản lý tiến độ công việc chuyên biệt cho phòng Marketing, xây dựng theo kiến trúc **Backend + Frontend** tách rời. Hệ thống hỗ trợ theo dõi tiến độ công việc, phân bổ dự án, thống kê hiệu suất nhân viên và báo cáo tổng quan theo thời gian thực.

---

## 📌 Thông tin Đề tài

- **Tên đề tài:** Marketing CRM (Ứng dụng Quản lý Tiến độ Công việc Phòng Marketing)
- **Người phụ trách đề tài:** **Nguyễn Trọng Tín** (1 người phụ trách duy nhất — Đảm nhận 100% phát triển Backend & Frontend)
- **Nền tảng hỗ trợ:** Android, iOS, Windows, macOS, Linux, Web

---

## 🏗 1. Kiến trúc Hệ thống & Công nghệ

Hệ thống được thiết kế theo mô hình **Client - Server (RESTful API)** tách biệt hoàn toàn giữa ứng dụng di động/desktop (Frontend) và máy chủ dịch vụ dữ liệu (Backend).

```
┌────────────────────────────────────────────────────────┐
│                   Frontend (Flutter)                   │
│   Material 3 UI │ Provider State Management │ Http Client │
└───────────────────────────┬────────────────────────────┘
                            │  HTTP Requests (JSON)
                            ▼  `http://<IP-Backend>:3000/api`
┌────────────────────────────────────────────────────────┐
│               Backend REST API (Node.js)                │
│       Express.js Server │ Native Node:SQLite Engine        │
└───────────────────────────┬────────────────────────────┘
                            │  SQL Queries (WAL Mode)
                            ▼
┌────────────────────────────────────────────────────────┐
│              SQLite Database (crm_marketing.db)         │
│               employees │ projects │ tasks             │
└────────────────────────────────────────────────────────┘
```

### 🛠 Công nghệ sử dụng

| Tầng | Công nghệ / Thư viện | Mô tả |
|---|---|---|
| **Backend Framework** | Node.js (>= 22.5.0), Express.js 4.x | Máy chủ HTTP RESTful API (Port 3000) |
| **Cơ sở dữ liệu** | SQLite (`node:sqlite` - `DatabaseSync`) | Lưu trữ dữ liệu chuẩn SQL, bật cơ chế WAL |
| **Frontend Framework** | Flutter (Dart >= 3.0.0) | Xây dựng giao diện Material Design 3 đa nền tảng |
| **Quản lý trạng thái** | `provider` (^6.1.1) | State management theo mô hình `ChangeNotifier` |
| **Giao tiếp API** | `http` (^1.2.0) | Gửi và nhận dữ liệu JSON chuẩn RESTful |
| **Định dạng & Tiện ích** | `intl`, `google_fonts`, `flutter_slidable` | Format ngày tháng tiếng Việt, font Outfit, vuốt thao tác task |

---

## 📁 2. Cấu trúc Dự án (Repository Structure)

```
CRMMarketing/
├── README.md                      → Tài liệu hướng dẫn chính của hệ thống
├── backend/                       → Máy chủ Backend (Node.js REST API)
│   ├── package.json               → Cấu hình dependencies & scripts Node.js
│   ├── server.js                  → Entry point khởi chạy Express Server (Port 3000)
│   └── src/
│       ├── db.js                  → Khởi tạo SQLite DB, tạo bảng & seed dữ liệu mẫu
│       └── routes/
│           ├── index.js           → Router chính gom tất cả các sub-routes
│           ├── auth.js            → API xác thực / đăng nhập (`/api/auth`)
│           ├── employees.js       → API quản lý nhân viên (`/api/employees`)
│           ├── projects.js        → API quản lý dự án (`/api/projects`)
│           ├── tasks.js           → API quản lý công việc (`/api/tasks`)
│           └── stats.js           → API thống kê & báo cáo (`/api/stats`)
└── frontend/                      → Ứng dụng Frontend (Flutter App)
    ├── pubspec.yaml               → Cấu hình package & tài nguyên Flutter
    ├── docs/
    │   └── README.md              → Tài liệu kỹ thuật chi tiết dành cho Frontend
    └── lib/
        ├── main.dart              → Điểm chạy đầu tiên của Flutter app
        ├── app.dart               → Cấu hình MaterialApp, Theme & Provider Setup
        ├── models/                → Đóng gói đối tượng dữ liệu (Data Models)
        │   ├── employee.dart      → Model Nhân viên (Employee)
        │   ├── project.dart       → Model Dự án (Project)
        │   └── task.dart          → Model Công việc (MarketingTask)
        ├── providers/             → Quản lý trạng thái ứng dụng (State Management)
        │   ├── auth_provider.dart → Quản lý phiên đăng nhập người dùng
        │   └── task_provider.dart → Quản lý danh sách task, bộ lọc & thống kê
        ├── services/              → Tầng giao tiếp HTTP / REST API
        │   ├── api_service.dart   → Thực hiện các request GET, POST, PUT, DELETE
        │   └── auth_service.dart  → Xử lý logic đăng nhập / đăng xuất
        ├── utils/                 → Hằng số, Theme & Tiện ích
        │   ├── constants.dart     → Cấu hình `apiHost`, `apiPort`, màu sắc & string
        │   ├── date_utils.dart    → Tiện ích format thời gian & kiểm tra hạn task
        │   └── theme.dart         → Cấu hình chủ đề Material Design 3
        ├── widgets/               → Component UI tái sử dụng
        │   ├── task_card.dart     → Thẻ hiển thị tóm tắt công việc
        │   ├── status_badge.dart   → Nhãn trạng thái (Cần làm / Đang làm / Kiểm tra / Xong)
        │   ├── priority_badge.dart → Nhãn mức ưu tiên (Thấp / Trung bình / Cao / Gấp)
        │   ├── stats_card.dart    → Thẻ thống kê chỉ số
        │   └── empty_state.dart   → Giao diện hiển thị khi danh sách rỗng
        └── screens/               → Giao diện màn hình ứng dụng
            ├── main_shell.dart    → Khung điều hướng chính (Bottom Navigation 4 Tab)
            ├── login/             → Màn hình đăng nhập (`LoginScreen`)
            ├── dashboard/         → Tab 1: Màn hình Tổng quan (`DashboardScreen`)
            ├── tasks/             → Tab 2: Quản lý công việc (`TaskList`, `TaskDetail`, `TaskForm`)
            ├── statistics/        → Tab 3: Màn hình Thống kê (`StatisticsScreen`)
            └── profile/           → Tab 4: Màn hình Cá nhân (`ProfileScreen`)
```

---

## 🗄 3. Mô hình Cơ sở Dữ liệu (Database Schema)

Cơ sở dữ liệu SQLite (`crm_marketing.db`) sử dụng các bảng có quan hệ ràng buộc khóa ngoại (Foreign Key `ON DELETE SET NULL`):

```
┌──────────────────────────────────────┐          ┌──────────────────────────────────────┐
│              employees               │          │               projects               │
├──────────────────────────────────────┤          ├──────────────────────────────────────┤
│ id (PK, AUTOINCREMENT)               │          │ id (PK, AUTOINCREMENT)               │
│ name (TEXT, NOT NULL)                │          │ name (TEXT, NOT NULL)                │
│ email (TEXT, NOT NULL)               │          │ description (TEXT)                   │
│ phone (TEXT)                         │          │ start_date (TEXT)                    │
│ position (TEXT)                      │          │ end_date (TEXT)                      │
│ avatar (TEXT)                        │          │ status (TEXT, DEFAULT 'active')      │
│ created_at (TEXT)                    │          │ created_at (TEXT)                    │
└──────────────────┬───────────────────┘          └──────────────────┬───────────────────┘
                   │                                                 │
                   │ (1)                                             │ (1)
                   │                                                 │
                   └──────────────────┐           ┌──────────────────┘
                                      │           │
                                  (N) ▼           ▼ (N)
                               ┌──────────────────────────────────────┐
                               │                tasks                 │
                               ├──────────────────────────────────────┤
                               │ id (PK, AUTOINCREMENT)               │
                               │ title (TEXT, NOT NULL)               │
                               │ description (TEXT)                   │
                               │ project_id (FK -> projects.id)       │
                               │ assignee_id (FK -> employees.id)     │
                               │ status (TEXT, DEFAULT 'todo')        │
                               │ priority (TEXT, DEFAULT 'medium')    │
                               │ start_date (TEXT)                    │
                               │ due_date (TEXT)                      │
                               │ completed_at (TEXT)                  │
                               │ progress (INTEGER, DEFAULT 0)        │
                               │ created_at (TEXT)                    │
                               │ updated_at (TEXT)                    │
                               └──────────────────────────────────────┘
```

### 👤 Dữ liệu khởi tạo mẫu (Seed Data)

Khi khởi chạy Backend lần đầu, hệ thống sẽ tự động chèn dữ liệu mẫu:

1. **Nhân viên (Employees):**
   - `Nguyễn Trọng Tín` (`tin.nguyen@company.com`) — *Trưởng phòng Marketing (Người phụ trách chính)*
   - `Trần Thị Bình` (`binh.tran@company.com`) — *Chuyên viên Content*
   - `Lê Hoàng Cường` (`cuong.le@company.com`) — *Chuyên viên SEO*
   - `Phạm Minh Dung` (`dung.pham@company.com`) — *Designer*
   - `Hoàng Thị Em` (`em.hoang@company.com`) — *Chuyên viên Social Media*

2. **Dự án (Projects):**
   - *Chiến dịch Quảng cáo Q3* (`active`)
   - *Tái thiết Website* (`active`)
   - *Chiến dịch Email Marketing* (`active`)

3. **Công việc (Tasks):** 7 công việc mẫu với đầy đủ các mức độ ưu tiên (`low`, `medium`, `high`, `urgent`) và trạng thái (`todo`, `in_progress`, `review`, `done`).

---

## 🌐 4. Chi tiết Danh sách REST API Endpoints

Tất cả các Endpoint đều hoạt động dưới đường dẫn gốc: `http://<IP-máy>:3000/api`

### 4.1 Xác thực (Authentication)

| Method | Endpoint | Request Body | Mô tả | Response |
|---|---|---|---|---|
| `POST` | `/api/auth/login` | `{ "email": "tin.nguyen@company.com" }` | Đăng nhập bằng email nhân viên | Trả về thông tin `Employee` object |

### 4.2 Quản lý Nhân viên (Employees)

| Method | Endpoint | Request Body / Query | Mô tả |
|---|---|---|---|
| `GET` | `/api/employees` | - | Lấy danh sách tất cả nhân viên |
| `GET` | `/api/employees/:id` | - | Lấy thông tin chi tiết 1 nhân viên |
| `POST` | `/api/employees` | `{ name, email, phone, position, avatar }` | Thêm mới nhân viên |
| `PUT` | `/api/employees/:id` | `{ name, email, phone, position, avatar }` | Cập nhật thông tin nhân viên |
| `DELETE` | `/api/employees/:id` | - | Xóa nhân viên |

### 4.3 Quản lý Dự án (Projects)

| Method | Endpoint | Request Body / Query | Mô tả |
|---|---|---|---|
| `GET` | `/api/projects` | - | Lấy danh sách tất cả dự án |
| `GET` | `/api/projects/:id` | - | Lấy chi tiết dự án |
| `POST` | `/api/projects` | `{ name, description, start_date, end_date, status }` | Tạo dự án mới |
| `PUT` | `/api/projects/:id` | `{ name, description, start_date, end_date, status }` | Cập nhật dự án |
| `DELETE` | `/api/projects/:id` | - | Xóa dự án |

### 4.4 Quản lý Công việc (Tasks)

| Method | Endpoint | Query Parameters / Body | Mô tả |
|---|---|---|---|
| `GET` | `/api/tasks` | `?status=all&assigneeId=1&projectId=1&search=banner` | Lấy danh sách task (lọc theo trạng thái, người làm, dự án, từ khóa) |
| `GET` | `/api/tasks/:id` | - | Lấy chi tiết 1 task (kèm thông tin assignee & project) |
| `POST` | `/api/tasks` | `{ title, description, project_id, assignee_id, status, priority, start_date, due_date, progress }` | Tạo mới công việc |
| `PUT` | `/api/tasks/:id` | `{ title, description, project_id, assignee_id, status, priority, progress, ... }` | Cập nhật công việc (tự set `completed_at` khi `status = 'done'`) |
| `DELETE` | `/api/tasks/:id` | - | Xóa công việc |

### 4.5 Thống kê & Báo cáo (Statistics)

| Method | Endpoint | Query Parameters | Mô tả | Response Format |
|---|---|---|---|---|
| `GET` | `/api/stats/dashboard` | `?employeeId=1` (Optional) | Thống kê số lượng task theo trạng thái + số task quá hạn | `{ total, todo, in_progress, review, done, overdue }` |
| `GET` | `/api/stats/employees-completion` | - | Phân tích % hoàn thành công việc theo từng nhân viên | `{ "Nguyễn Trọng Tín": 80.0, "Trần Thị Bình": 50.0, ... }` |
| `GET` | `/api/stats/priority` | - | Phân bố số lượng công việc theo độ ưu tiên | `{ "low": 1, "medium": 3, "high": 2, "urgent": 1 }` |

---

## 🎯 5. Chi tiết Phân chia Phạm vi & Chức năng Mô-đun

Dự án do **1 người phụ trách duy nhất là Nguyễn Trọng Tín** đảm nhận toàn bộ từ thiết kế cơ sở dữ liệu, viết API Backend cho tới phát triển giao diện & logic trên Frontend.

### 👤 Mô-đun 1: Dashboard & Xác thực (Auth + Overview)
- **Người thực hiện:** **Nguyễn Trọng Tín**
- **File phụ trách:** `lib/screens/login/login_screen.dart`, `lib/screens/dashboard/dashboard_screen.dart`, `lib/providers/auth_provider.dart`, `lib/services/auth_service.dart`, `lib/screens/main_shell.dart`.
- **Chức năng:**
  - Màn hình đăng nhập xác thực nhanh theo email nhân viên mẫu.
  - Khung điều hướng Bottom Navigation 4 tab chuyển đổi mượt mà.
  - Dashboard hiển thị các thẻ thống kê tổng quan (Tổng số task, Cần làm, Đang làm, Kiểm tra, Hoàn thành, Quá hạn) và danh sách task mới cập nhật.

### 👤 Mô-đun 2: Quản lý Công việc (Task Management)
- **Người thực hiện:** **Nguyễn Trọng Tín**
- **File phụ trách:** `lib/screens/tasks/task_list_screen.dart`, `lib/screens/tasks/task_detail_screen.dart`, `lib/screens/tasks/task_form_screen.dart`, `lib/widgets/task_card.dart`, `lib/widgets/status_badge.dart`, `lib/widgets/priority_badge.dart`.
- **Chức năng:**
  - Danh sách công việc thông minh: Lọc nhanh theo Tab trạng thái (`Tất cả`, `Cần làm`, `Đang làm`, `Kiểm tra`, `Xong`), tìm kiếm theo từ khóa, lọc theo người thực hiện.
  - Màn hình chi tiết công việc: Hiển thị dòng thời gian, thời hạn (Due date), độ ưu tiên và quy trình 4 bước chuyển trạng thái (`todo` ➔ `in_progress` ➔ `review` ➔ `done`).
  - Màn hình form Thêm / Sửa công việc: Chọn dự án, người thực hiện, mức ưu tiên, ngày bắt đầu & ngày hết hạn.
  - Thao tác xóa task với hộp thoại xác nhận an toàn.

### 👤 Mô-đun 3: Thống kê & Báo cáo (Statistics & Analytics)
- **Người thực hiện:** **Nguyễn Trọng Tín**
- **File phụ trách:** `lib/screens/statistics/statistics_screen.dart`, `lib/widgets/stats_card.dart`.
- **Chức năng:**
  - Biểu đồ tiến độ tỷ lệ hoàn thành công việc tổng thể của toàn bộ phòng Marketing.
  - Biểu đồ phân bố độ ưu tiên của công việc dạng thanh phần trăm (Thấp, Trung bình, Cao, Gấp).
  - Bảng đo lường hiệu suất làm việc (% công việc đã hoàn thành) của từng nhân viên.

### 👤 Mô-đun 4: Cá nhân & Tầng dịch vụ (Profile & Service Infrastructure)
- **Người thực hiện:** **Nguyễn Trọng Tín**
- **File phụ trách:** `lib/screens/profile/profile_screen.dart`, `lib/services/api_service.dart`, `lib/models/*`, `lib/providers/task_provider.dart`, `lib/utils/*`.
- **Chức năng:**
  - Màn hình Profile cá nhân: Hiển thị avatar đại diện (Initials), tên, email, chức vụ, sđt và thống kê nhanh số task của cá nhân.
  - Xử lý Đăng xuất và xóa session đăng nhập.
  - Tầng `ApiService`: Đóng gói toàn bộ các hàm gọi HTTP REST API an toàn với cơ chế bắt lỗi timeout/error response.
  - Tầng `TaskProvider`: Quản lý state toàn cục cho danh sách task, tự động đồng bộ dữ liệu sau khi thêm/sửa/xóa task.

---

## 🚀 6. Hướng dẫn Cài đặt & Vận hành

### 📋 Yêu cầu môi trường
1. **Node.js**: Phiên bản `>= 22.5.0` (để sử dụng module native `node:sqlite`).
2. **Flutter SDK**: Phiên bản `>= 3.0.0`.
3. **Thiết bị chạy**: Máy mô phỏng (Emulator/Simulator), trình duyệt Web hoặc thiết bị thật kết nối cùng mạng WiFi/LAN.

---

### ⚡ Bước 1: Khởi chạy Backend Server (Port 3000)

```bash
# 1. Di chuyển vào thư mục backend
cd backend

# 2. Cài đặt các gói phụ thuộc
npm install

# 3. Khởi chạy server
npm start
```

- Backend sẽ khởi tạo cơ sở dữ liệu SQLite `crm_marketing.db` và nạp sẵn dữ liệu mẫu.
- API bắt đầu lắng nghe tại: `http://localhost:3000/api` (hoặc `http://0.0.0.0:3000/api`).

---

### 📱 Bước 2: Khởi chạy Frontend (Flutter App)

#### ⚙️ Cấu hình địa chỉ IP Backend:
Mở file `frontend/lib/utils/constants.dart`, cập nhật `apiHost` thành địa chỉ IP máy tính đang chạy Backend:

```dart
class AppConfig {
  // Thay 'localhost' hoặc '192.168.x.x' bằng IP máy tính của bạn khi chạy trên thiết bị thật/emulator
  static const String apiHost = 'http://localhost:3000/api'; 
}
```

#### 🚀 Chạy ứng dụng Flutter:

```bash
# 1. Di chuyển vào thư mục frontend
cd frontend

# 2. Lấy các gói phụ thuộc Flutter
flutter pub get

# 3. Khởi chạy ứng dụng
flutter run
```

---

## 🔑 7. Tài khoản Đăng nhập Mẫu để Kiểm thử

Bạn có thể sử dụng email của người phụ trách chính hoặc bất kỳ nhân viên mẫu nào bên dưới để đăng nhập vào ứng dụng (mật khẩu có thể nhập bất kỳ):

| Họ và Tên | Email Đăng nhập | Chức vụ |
|---|---|---|
| **Nguyễn Trọng Tín** *(Chính)* | `tin.nguyen@company.com` | **Trưởng phòng Marketing (Người phụ trách)** |
| Trần Thị Bình | `binh.tran@company.com` | Chuyên viên Content |
| Lê Hoàng Cường | `cuong.le@company.com` | Chuyên viên SEO |
| Phạm Minh Dung | `dung.pham@company.com` | Designer |
| Hoàng Thị Em | `em.hoang@company.com` | Chuyên viên Social Media |

---

## 📝 8. Giấy phép & Tác quyền

- **Đồ án / Đề tài:** Marketing CRM
- **Tác giả & Người phụ trách:** **Nguyễn Trọng Tín**
- **Bản quyền:** © 2026 Nguyễn Trọng Tín. All rights reserved.
