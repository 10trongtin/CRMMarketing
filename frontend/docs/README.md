# Marketing CRM

Ứng dụng quản lý tiến độ công việc phòng Marketing — Flutter (FE) kết nối backend REST API (Node.js + Express + SQLite) qua IP máy, cổng 3000.

---

## 1. Công nghệ sử dụng

| Thành phần | Công nghệ |
|---|---|
| Framework (FE) | Flutter (Material 3) |
| Ngôn ngữ | Dart (>=3.0.0) |
| State management | Provider + ChangeNotifier |
| API client | `http` package → `ApiService` |
| Backend (BE) | Node.js + Express + SQLite (`node:sqlite`) |
| Port API | 3000 |
| UI | Material Design 3, google_fonts, flutter_slidable |
| Charts | fl_chart (chưa dùng, đã khai báo) |
| Localization | intl (Tiếng Việt, English fallback) |
| Nền tảng | Android, iOS, Web, Linux, macOS, Windows |

**Cấu trúc repo:**
```
crm/
├── backend/   → REST API (Node.js + Express + SQLite)
└── frontend/  → Flutter app
```

---

## 2. Kiến trúc tổng quan

Ứng dụng theo mô hình **Provider + Service (API Client)** — frontend không lưu dữ liệu local, mọi thao tác đều gọi REST API của backend ở `http://<IP-máy>:3000/api`.

```
UI Layer (Screens)
    ↕ context.watch / context.read
Provider Layer (ChangeNotifier)
    ↕ gọi phương thức của ApiService
Service Layer (ApiService / AuthService)
    ↕ HTTP requests (JSON)
Backend REST API (Node.js + Express + SQLite) — port 3000
```

**Luồng dữ liệu điển hình:**

1. Người dùng tương tác (tap, nhập liệu) trên **Screen**
2. Screen gọi method trên **Provider** qua `context.read`
3. Provider gọi method trên **ApiService** (`lib/services/api_service.dart`)
4. ApiService gửi HTTP request → backend xử lý truy vấn SQLite
5. Backend trả JSON → ApiService parse thành Model
6. Provider cập nhật state, gọi `notifyListeners()`
7. UI rebuild qua `context.watch`

---

## 3. Mô hình dữ liệu

### 3.1 Employee (Nhân viên)

| Trường | Kiểu | Ghi chú |
|---|---|---|
| id | int? | PK, auto-increment |
| name | String | Bắt buộc |
| email | String | Dùng để đăng nhập |
| phone | String | |
| position | String | Chức vụ |
| avatar | String? | |
| createdAt | DateTime? | |

### 3.2 Project (Dự án)

| Trường | Kiểu | Ghi chú |
|---|---|---|
| id | int? | PK, auto-increment |
| name | String | Bắt buộc |
| description | String | |
| startDate | DateTime? | |
| endDate | DateTime? | |
| status | String | `active`, `completed`, `paused`, `cancelled` |
| createdAt | DateTime? | |

### 3.3 MarketingTask (Công việc)

| Trường | Kiểu | Ghi chú |
|---|---|---|
| id | int? | PK, auto-increment |
| title | String | Bắt buộc |
| description | String | |
| projectId | int? | FK → projects(id) |
| assigneeId | int? | FK → employees(id) |
| status | String | `todo`, `in_progress`, `review`, `done` |
| priority | String | `low`, `medium`, `high`, `urgent` |
| startDate | DateTime? | |
| dueDate | DateTime? | |
| completedAt | DateTime? | |
| progress | int | 0–100 |
| createdAt | DateTime? | |
| updatedAt | DateTime? | |

### 3.4 Quan hệ

```
Employee (1) ───< (N) MarketingTask >─── (N) Project (1)
```

Một Employee có nhiều Task; một Project có nhiều Task. Foreign key dùng `ON DELETE SET NULL`.

---

## 4. Phân chia các mô-đun chức năng

Dự án được thiết kế thành **4 mô-đun chức năng chính** tương ứng với 4 tab điều hướng giao diện:

### 🧩 Mô-đun 1 — Tổng quan & Xác thực (Dashboard + Auth)
- **Các file chính:**
  | File | Vai trò |
  |---|---|
  | `lib/main.dart` | Entry point |
  | `lib/app.dart` | MaterialApp, Provider setup, routing |
  | `lib/screens/dashboard/dashboard_screen.dart` | Màn hình Tổng quan |
  | `lib/providers/auth_provider.dart` | Quản lý trạng thái đăng nhập |
  | `lib/services/auth_service.dart` | Xử lý login/logout |
  | `lib/screens/login/login_screen.dart` | Màn hình đăng nhập |
  | `lib/screens/main_shell.dart` | Bottom navigation (4 tab) |

**Chức năng:**
- Khởi tạo ứng dụng, cấu hình Provider
- Đăng nhập bằng email nhân viên
- Bottom navigation với 4 tab
- Dashboard tổng quan: thống kê số lượng task theo trạng thái, danh sách task gần đây

---

### 📋 Mô-đun 2 — Quản lý Công việc (Tasks)
- **Các file chính:**
  | File | Vai trò |
  |---|---|
  | `lib/screens/tasks/task_list_screen.dart` | Danh sách công việc (lọc, tìm kiếm) |
  | `lib/screens/tasks/task_detail_screen.dart` | Chi tiết công việc + cập nhật trạng thái |
  | `lib/screens/tasks/task_form_screen.dart` | Thêm / Sửa công việc |
  | `lib/widgets/task_card.dart` | Card hiển thị tóm tắt công việc |
  | `lib/widgets/status_badge.dart` | Badge trạng thái (Cần làm/Đang làm/Kiểm tra/Xong) |
  | `lib/widgets/priority_badge.dart` | Badge mức ưu tiên (Thấp/TB/Cao/Gấp) |

**Chức năng:**
- Xem danh sách công việc, lọc theo trạng thái và người thực hiện
- Tìm kiếm công việc theo tiêu đề / mô tả
- Thêm công việc mới: tiêu đề, mô tả, người thực hiện, dự án, độ ưu tiên, ngày tháng
- Xem chi tiết: thông tin đầy đủ, dòng thời gian, tiến độ
- Cập nhật trạng thái (4 bước: Cần làm → Đang làm → Kiểm tra → Xong)
- Cập nhật tiến độ phần trăm (0%, 25%, 50%, 75%, 100%)
- Xoá công việc

---

### 📊 Mô-đun 3 — Thống kê (Statistics)
- **Các file chính:**
  | File | Vai trò |
  |---|---|
  | `lib/screens/statistics/statistics_screen.dart` | Màn hình Thống kê |
  | `lib/widgets/stats_card.dart` | Card hiển thị chỉ số |

**Chức năng:**
- Tỷ lệ hoàn thành tổng thể (số phần trăm + thanh progress)
- Phân bố độ ưu tiên (Thấp / Trung bình / Cao / Gấp) — thanh ngang kèm %
- Hiệu suất từng nhân viên (% hoàn thành công việc được giao)
- Thông tin bổ sung: quá hạn, đã xong, đang thực hiện

---

### ⚙️ Mô-đun 4 — Cá nhân & Tầng dịch vụ (Profile + Services + Models + Utils)
- **Các file chính:**
  | File | Vai trò |
  |---|---|
  | `lib/screens/profile/profile_screen.dart` | Màn hình Cá nhân |
  | `lib/services/api_service.dart` | Toàn bộ gọi REST API (auth, employees, projects, tasks, stats) |
  | `lib/models/employee.dart` | Model Employee |
  | `lib/models/project.dart` | Model Project |
  | `lib/models/task.dart` | Model MarketingTask + logic nghiệp vụ |
  | `lib/providers/task_provider.dart` | State management cho Tasks |
  | `lib/utils/constants.dart` | Màu sắc, hằng số, cấu hình |
  | `lib/utils/theme.dart` | Material 3 theme |
  | `lib/utils/date_utils.dart` | Xử lý ngày tháng (format, so sánh, relative time) |
  | `lib/widgets/empty_state.dart` | Widget placeholder khi danh sách rỗng |

**Chức năng:**
- Xem thông tin cá nhân (tên, email, chức vụ)
- Thống kê cá nhân nhanh (tổng task, đang làm, đã xong)
- Đăng xuất
- **Tầng dịch vụ:** tất cả thao tác gọi REST API — auth, tasks, employees, projects, stats (`lib/services/api_service.dart`)
- **Tầng model:** định nghĩa cấu trúc dữ liệu + logic nghiệp vụ (kiểm tra quá hạn, label tiếng Việt)
- **Tầng Provider:** quản lý state toàn cục cho task (lọc, tìm kiếm, phân quyền dữ liệu theo user)

---

## 5. Luồng hoạt động chi tiết

### 5.1 Đăng nhập

```
[LoginScreen] → nhập email → AuthProvider.login()
    → AuthService.login() → ApiService.login()
    → POST /api/auth/login → backend tìm employee theo email
    → set _currentUser → chuyển sang MainShell (4 tab)
```

### 5.2 Tạo công việc mới

```
[TaskListScreen] → FAB [+] → TaskFormScreen
    → nhập: tiêu đề, mô tả, người làm, dự án, độ ưu tiên, ngày tháng
    → bấm "Thêm mới" → TaskProvider.addTask()
    → ApiService.insertTask() → POST /api/tasks
    → loadTasks() → GET /api/tasks → notifyListeners() → UI cập nhật
    → Navigator.pop()
```

### 5.3 Cập nhật trạng thái (luồng 4 bước)

```
Cần làm (todo) ──→ Đang làm (in_progress) ──→ Kiểm tra (review) ──→ Hoàn thành (done)
```

Trên màn hình chi tiết:
```
[TaskDetailScreen] → tap vào status step
    → TaskProvider.updateTaskStatus(id, newStatus)
    → Nếu newStatus == 'done' → set completedAt = now, progress = 100
    → ApiService.updateTask() → PUT /api/tasks/:id
    → loadTasks() → UI rebuild
```

### 5.4 Dashboard — Tải thống kê

```
[DashboardScreen] initState() → _loadStats()
    → TaskProvider.getDashboardStats()
    → ApiService.getDashboardStats(employeeId)
    → GET /api/stats/dashboard → 6 truy vấn COUNT
    → Trả về Map → UI render grid 6 ô + biểu đồ phân bố + 5 task gần đây
```

### 5.5 Lọc và tìm kiếm công việc

```
[TaskListScreen]
    ├── Status tabs (Tất cả / Cần làm / Đang làm / Kiểm tra / Xong)
    │   → setStatusFilter() → loadTasks() với WHERE status = ?
    ├── Thanh tìm kiếm
    │   → setSearchQuery() → loadTasks() với WHERE title LIKE ?
    └── Bottom sheet lọc theo người
        → setCurrentEmployee() → loadTasks() với WHERE assignee_id = ?
```

### 5.6 Thống kê — Hiệu suất nhân viên

```
[StatisticsScreen] initState() → _loadStats()
    → TaskProvider.getEmployeeCompletionStats()
    → ApiService.getTaskCompletionByEmployee()
    → GET /api/stats/employees-completion
    → Backend: GROUP BY employees, COUNT tasks, SUM(CASE WHEN done)
    → Tính % hoàn thành cho từng người
    → UI render thanh progress cho mỗi employee
```

### 5.7 Vòng đời task

```
1. Tạo → status: todo, progress: 0
2. Bắt đầu làm → status: in_progress, progress: > 0
3. Làm xong, gửi kiểm tra → status: review, progress: ≥ 80
4. Duyệt, hoàn thành → status: done, progress: 100, completedAt: now
5. (Nếu quá dueDate mà chưa done) → isOverdue = true
```

---

## 6. Cấu trúc thư mục

```
lib/
├── main.dart
├── app.dart
├── models/
│   ├── employee.dart
│   ├── project.dart
│   └── task.dart
├── providers/
│   ├── auth_provider.dart
│   └── task_provider.dart
├── screens/
│   ├── main_shell.dart
│   ├── login/login_screen.dart
│   ├── dashboard/dashboard_screen.dart
│   ├── tasks/
│   │   ├── task_list_screen.dart
│   │   ├── task_detail_screen.dart
│   │   └── task_form_screen.dart
│   ├── statistics/statistics_screen.dart
│   └── profile/profile_screen.dart
├── services/
│   ├── api_service.dart
│   └── auth_service.dart
├── utils/
│   ├── constants.dart
│   ├── date_utils.dart
│   └── theme.dart
└── widgets/
    ├── empty_state.dart
    ├── priority_badge.dart
    ├── stats_card.dart
    ├── status_badge.dart
    └── task_card.dart
```

---

## 7. Dữ liệu mẫu (seed)

Khi chạy lần đầu, database được tạo và chèn sẵn:

**Nhân viên (5):**
| Tên | Email | Chức vụ |
|---|---|---|
| Nguyễn Văn An | an.nguyen@company.com | Trưởng phòng Marketing |
| Trần Thị Bình | binh.tran@company.com | Chuyên viên Content |
| Lê Hoàng Cường | cuong.le@company.com | Chuyên viên SEO |
| Phạm Minh Dung | dung.pham@company.com | Designer |
| Hoàng Thị Em | em.hoang@company.com | Chuyên viên Social Media |

**Dự án (3):** Chiến dịch Quảng cáo Q3, Tái thiết Website, Chiến dịch Email Marketing.

**Công việc (7):** Phân bổ cho các thành viên với trạng thái và độ ưu tiên khác nhau.

---

## 8. Hướng dẫn chạy

### Bước 1 — Chạy backend (port 3000)

```bash
cd backend
npm install
npm start
```

API chạy tại `http://0.0.0.0:3000/api`, seed dữ liệu mẫu tự động khi chạy lần đầu.

### Bước 2 — Chạy frontend (Flutter)

```bash
cd frontend
flutter pub get
flutter run
```

App kết nối backend qua `http://<IP-máy>:3000/api` (cấu hình tại `lib/utils/constants.dart` — `AppConfig.apiHost`).

Chọn email bất kỳ từ danh sách mẫu để đăng nhập (mật khẩu không kiểm tra).

## 9. Danh sách API

| Method | Endpoint | Mô tả |
|---|---|---|
| POST | `/api/auth/login` | Đăng nhập bằng email |
| GET/POST | `/api/employees` | Danh sách / tạo nhân viên |
| GET/PUT/DELETE | `/api/employees/:id` | Chi tiết / sửa / xoá nhân viên |
| GET/POST | `/api/projects` | Danh sách / tạo dự án |
| GET/PUT/DELETE | `/api/projects/:id` | Chi tiết / sửa / xoá dự án |
| GET/POST | `/api/tasks` | Danh sách (lọc status/assigneeId/projectId/search) / tạo công việc |
| GET/PUT/DELETE | `/api/tasks/:id` | Chi tiết / sửa / xoá công việc |
| GET | `/api/stats/dashboard` | Thống kê tổng quan (`?employeeId=`) |
| GET | `/api/stats/employees-completion` | % hoàn thành theo nhân viên |
| GET | `/api/stats/priority` | Phân bố độ ưu tiên |
