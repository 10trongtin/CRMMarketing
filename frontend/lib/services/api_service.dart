import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';
import '../models/employee.dart';
import '../models/project.dart';
import '../utils/constants.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  static const _base = AppConfig.apiBaseUrl;

  static Uri _uri(String path, [Map<String, dynamic>? query]) {
    final base = Uri.parse('$_base$path');
    if (query == null || query.isEmpty) return base;
    return base.replace(
      queryParameters: query.map((key, value) => MapEntry(key, value.toString())),
    );
  }

  static Map<String, dynamic> _decode(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return {};
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    String message = 'Lỗi máy chủ (${res.statusCode})';
    try {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (body['error'] is String) message = body['error'] as String;
    } catch (_) {}
    throw ApiException(message);
  }

  static Future<Map<String, dynamic>> _get(String path, [Map<String, dynamic>? query]) async {
    final res = await http.get(_uri(path, query));
    return _decode(res);
  }

  static Future<Map<String, dynamic>> _post(String path, [Map<String, dynamic>? body]) async {
    final res = await http.post(
      _uri(path),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body ?? const {}),
    );
    return _decode(res);
  }

  static Future<Map<String, dynamic>> _put(String path, [Map<String, dynamic>? body]) async {
    final res = await http.put(
      _uri(path),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body ?? const {}),
    );
    return _decode(res);
  }

  static Future<void> _delete(String path) async {
    final res = await http.delete(_uri(path));
    if (res.statusCode != 204 && res.statusCode != 200) {
      _decode(res);
    }
  }

  // ---- Auth ----

  static Future<Employee> login(String email, String password) async {
    final json = await _post('/auth/login', {
      'email': email,
      'password': password,
    });
    return Employee.fromMap(json);
  }

  static Future<void> logout() async {
    await _post('/auth/logout');
  }

  // ---- Employees ----

  static Future<List<Employee>> getEmployees() async {
    final res = await http.get(_uri('/employees'));
    if (res.statusCode != 200) {
      _decode(res);
    }
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((e) => Employee.fromMap(e as Map<String, dynamic>)).toList();
  }

  static Future<Employee?> getEmployee(int id) async {
    final res = await http.get(_uri('/employees/$id'));
    if (res.statusCode == 404) return null;
    return Employee.fromMap(_decode(res));
  }

  static Future<int> insertEmployee(Employee employee) async {
    final json = await _post('/employees', employee.toMap());
    return json['id'] as int? ?? 0;
  }

  static Future<void> updateEmployee(Employee employee) async {
    await _put('/employees/${employee.id}', employee.toMap());
  }

  static Future<void> deleteEmployee(int id) async {
    await _delete('/employees/$id');
  }

  // ---- Projects ----

  static Future<List<Project>> getProjects() async {
    final res = await http.get(_uri('/projects'));
    if (res.statusCode != 200) {
      _decode(res);
    }
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((e) => Project.fromMap(e as Map<String, dynamic>)).toList();
  }

  static Future<Project?> getProject(int id) async {
    final res = await http.get(_uri('/projects/$id'));
    if (res.statusCode == 404) return null;
    return Project.fromMap(_decode(res));
  }

  static Future<int> insertProject(Project project) async {
    final json = await _post('/projects', project.toMap());
    return json['id'] as int? ?? 0;
  }

  static Future<void> updateProject(Project project) async {
    await _put('/projects/${project.id}', project.toMap());
  }

  static Future<void> deleteProject(int id) async {
    await _delete('/projects/$id');
  }

  // ---- Tasks ----

  static MarketingTask _taskFromJson(Map<String, dynamic> map) {
    final task = MarketingTask.fromMap(map);
    if (map['assignee_name'] != null) {
      task.assignee = Employee(
        id: map['assignee_id'] as int?,
        name: map['assignee_name'] as String? ?? '',
        email: map['assignee_email'] as String? ?? '',
        position: map['assignee_position'] as String? ?? '',
      );
    }
    if (map['project_name'] != null) {
      task.project = Project(
        id: map['project_id'] as int?,
        name: map['project_name'] as String? ?? '',
        status: map['project_status'] as String? ?? '',
      );
    }
    return task;
  }

  static Future<List<MarketingTask>> getTasks({
    String? statusFilter,
    int? assigneeId,
    int? projectId,
    String? searchQuery,
  }) async {
    final query = <String, dynamic>{};
    if (statusFilter != null && statusFilter != 'all') query['status'] = statusFilter;
    if (assigneeId != null) query['assigneeId'] = assigneeId;
    if (projectId != null) query['projectId'] = projectId;
    if (searchQuery != null && searchQuery.isNotEmpty) query['search'] = searchQuery;

    final res = await http.get(_uri('/tasks', query));
    if (res.statusCode != 200) {
      _decode(res);
    }
    final list = jsonDecode(res.body) as List<dynamic>;
    return list
        .map((e) => _taskFromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<MarketingTask?> getTask(int id) async {
    final res = await http.get(_uri('/tasks/$id'));
    if (res.statusCode == 404) return null;
    return _taskFromJson(_decode(res));
  }

  static Future<int> insertTask(MarketingTask task) async {
    final now = DateTime.now();
    final body = task.toMap();
    body['created_at'] ??= now.toIso8601String();
    body['updated_at'] ??= now.toIso8601String();
    final json = await _post('/tasks', body);
    return json['id'] as int? ?? 0;
  }

  static Future<void> updateTask(MarketingTask task) async {
    await _put('/tasks/${task.id}', task.toMap());
  }

  static Future<void> deleteTask(int id) async {
    await _delete('/tasks/$id');
  }

  // ---- Stats ----

  static Future<Map<String, dynamic>> getDashboardStats({int? employeeId}) async {
    final query = employeeId != null ? {'employeeId': employeeId} : null;
    return _get('/stats/dashboard', query);
  }

  static Future<Map<String, double>> getTaskCompletionByEmployee() async {
    final json = await _get('/stats/employees-completion');
    return json.map((key, value) => MapEntry(key, (value as num).toDouble()));
  }

  static Future<Map<String, int>> getTasksByPriority() async {
    final json = await _get('/stats/priority');
    return json.map((key, value) => MapEntry(key, (value as num).toInt()));
  }
}
