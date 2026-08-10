class AppColors {
  static const primary = 0xFF1565C0;
  static const primaryLight = 0xFF42A5F5;
  static const primaryDark = 0xFF0D47A1;
  static const secondary = 0xFF26A69A;
  static const accent = 0xFFFF7043;
  static const background = 0xFFF5F7FA;
  static const surface = 0xFFFFFFFF;
  static const textPrimary = 0xFF212121;
  static const textSecondary = 0xFF757575;
  static const divider = 0xFFE0E0E0;
  static const error = 0xFFE53935;
  static const success = 0xFF43A047;
  static const warning = 0xFFFFA726;
  static const info = 0xFF29B6F6;

  static const statusTodo = 0xFFBDBDBD;
  static const statusInProgress = 0xFF42A5F5;
  static const statusReview = 0xFFFFA726;
  static const statusDone = 0xFF66BB6A;

  static const priorityLow = 0xFF81C784;
  static const priorityMedium = 0xFFFFA726;
  static const priorityHigh = 0xFFEF5350;
  static const priorityUrgent = 0xFFD32F2F;
}

class AppStrings {
  static const appName = 'Marketing CRM';
  static const login = 'Đăng nhập';
  static const logout = 'Đăng xuất';
  static const email = 'Email';
  static const password = 'Mật khẩu';
  static const dashboard = 'Tổng quan';
  static const tasks = 'Công việc';
  static const statistics = 'Thống kê';
  static const profile = 'Cá nhân';
  static const addTask = 'Thêm công việc';
  static const editTask = 'Sửa công việc';
  static const delete = 'Xóa';
  static const cancel = 'Hủy';
  static const save = 'Lưu';
  static const title = 'Tiêu đề';
  static const description = 'Mô tả';
  static const dueDate = 'Hạn hoàn thành';
  static const assignee = 'Người thực hiện';
  static const status = 'Trạng thái';
  static const priority = 'Ưu tiên';
  static const progress = 'Tiến độ';
  static const noTasks = 'Chưa có công việc nào';
  static const search = 'Tìm kiếm...';
  static const allTasks = 'Tất cả công việc';
  static const myTasks = 'Công việc của tôi';
  static const pendingTasks = 'Chưa hoàn thành';
  static const completedTasks = 'Đã hoàn thành';
  static const overdue = 'Quá hạn';
  static const onTime = 'Đúng hạn';
}

class AppConfig {
  // Địa chỉ IP máy chạy backend + cổng 3000.
  // Đổi IP này theo IP máy thật khi deploy (vd: '192.168.1.103').
  static const apiHost = '192.168.1.103';
  static const apiPort = 3000;
  static const apiBaseUrl = 'http://$apiHost:$apiPort/api';
}
