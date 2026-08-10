import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../models/employee.dart';
import '../models/project.dart';
import '../services/api_service.dart';

class TaskProvider extends ChangeNotifier {
  List<MarketingTask> _tasks = [];
  List<Employee> _employees = [];
  List<Project> _projects = [];
  MarketingTask? _selectedTask;
  bool _isLoading = false;
  String _statusFilter = 'all';
  String _searchQuery = '';
  int? _currentEmployeeId;

  List<MarketingTask> get tasks => _tasks;
  List<Employee> get employees => _employees;
  List<Project> get projects => _projects;
  MarketingTask? get selectedTask => _selectedTask;
  bool get isLoading => _isLoading;
  String get statusFilter => _statusFilter;
  String get searchQuery => _searchQuery;
  int? get currentEmployeeId => _currentEmployeeId;

  List<MarketingTask> get filteredTasks {
    var result = _tasks;
    if (_currentEmployeeId != null) {
      result = result.where((t) => t.assigneeId == _currentEmployeeId).toList();
    }
    return result;
  }

  int get totalTasks => _tasks.length;
  int get todoTasks => _tasks.where((t) => t.status == 'todo').length;
  int get inProgressTasks => _tasks.where((t) => t.status == 'in_progress').length;
  int get reviewTasks => _tasks.where((t) => t.status == 'review').length;
  int get doneTasks => _tasks.where((t) => t.status == 'done').length;
  int get overdueTasks => _tasks.where((t) => t.isOverdue).length;

  void setCurrentEmployee(int? employeeId) {
    _currentEmployeeId = employeeId;
    notifyListeners();
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();
    try {
      _tasks = await ApiService.getTasks(
        statusFilter: _statusFilter,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
        assigneeId: _currentEmployeeId,
      );
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadEmployees() async {
    try {
      _employees = await ApiService.getEmployees();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading employees: $e');
    }
  }

  Future<void> loadProjects() async {
    try {
      _projects = await ApiService.getProjects();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading projects: $e');
    }
  }

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();
    await Future.wait([loadTasks(), loadEmployees(), loadProjects()]);
    _isLoading = false;
    notifyListeners();
  }

  void setStatusFilter(String filter) {
    _statusFilter = filter;
    loadTasks();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    loadTasks();
  }

  Future<void> selectTask(int id) async {
    _selectedTask = await ApiService.getTask(id);
    notifyListeners();
  }

  Future<void> addTask(MarketingTask task) async {
    final id = await ApiService.insertTask(task);
    if (id > 0) {
      await loadTasks();
    }
  }

  Future<void> updateTask(MarketingTask task) async {
    await ApiService.updateTask(task);
    await loadTasks();
  }

  Future<void> deleteTask(int id) async {
    await ApiService.deleteTask(id);
    if (_selectedTask?.id == id) {
      _selectedTask = null;
    }
    await loadTasks();
  }

  Future<void> updateTaskStatus(int taskId, String newStatus) async {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    task.status = newStatus;
    if (newStatus == 'done') {
      task.completedAt = DateTime.now();
      task.progress = 100;
    }
    await ApiService.updateTask(task);
    await loadTasks();
  }

  Future<void> updateTaskProgress(int taskId, int progress) async {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    task.progress = progress;
    if (progress == 100) {
      task.status = 'done';
      task.completedAt = DateTime.now();
    }
    await ApiService.updateTask(task);
    await loadTasks();
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    return ApiService.getDashboardStats(employeeId: _currentEmployeeId);
  }

  Future<Map<String, double>> getEmployeeCompletionStats() async {
    return ApiService.getTaskCompletionByEmployee();
  }

  Future<Map<String, int>> getPriorityStats() async {
    return ApiService.getTasksByPriority();
  }
}
