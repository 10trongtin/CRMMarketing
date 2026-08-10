import 'employee.dart';
import 'project.dart';

class MarketingTask {
  final int? id;
  final String title;
  final String description;
  final int? projectId;
  final int? assigneeId;
  String status;
  String priority;
  final DateTime? startDate;
  DateTime? dueDate;
  DateTime? completedAt;
  int progress;
  DateTime? createdAt;
  DateTime? updatedAt;

  Employee? assignee;
  Project? project;

  MarketingTask({
    this.id,
    required this.title,
    this.description = '',
    this.projectId,
    this.assigneeId,
    this.status = 'todo',
    this.priority = 'medium',
    this.startDate,
    this.dueDate,
    this.completedAt,
    this.progress = 0,
    this.createdAt,
    this.updatedAt,
    this.assignee,
    this.project,
  });

  factory MarketingTask.fromMap(Map<String, dynamic> map) {
    return MarketingTask(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      projectId: map['project_id'] as int?,
      assigneeId: map['assignee_id'] as int?,
      status: map['status'] as String? ?? 'todo',
      priority: map['priority'] as String? ?? 'medium',
      startDate: map['start_date'] != null ? DateTime.tryParse(map['start_date'] as String) : null,
      dueDate: map['due_date'] != null ? DateTime.tryParse(map['due_date'] as String) : null,
      completedAt: map['completed_at'] != null ? DateTime.tryParse(map['completed_at'] as String) : null,
      progress: map['progress'] as int? ?? 0,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'] as String) : null,
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'project_id': projectId,
      'assignee_id': assigneeId,
      'status': status,
      'priority': priority,
      'start_date': startDate?.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'progress': progress,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  MarketingTask copyWith({
    int? id,
    String? title,
    String? description,
    int? projectId,
    int? assigneeId,
    String? status,
    String? priority,
    DateTime? startDate,
    DateTime? dueDate,
    DateTime? completedAt,
    int? progress,
    DateTime? createdAt,
    DateTime? updatedAt,
    Employee? assignee,
    Project? project,
  }) {
    return MarketingTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      projectId: projectId ?? this.projectId,
      assigneeId: assigneeId ?? this.assigneeId,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      progress: progress ?? this.progress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      assignee: assignee ?? this.assignee,
      project: project ?? this.project,
    );
  }

  static const List<String> statuses = ['todo', 'in_progress', 'review', 'done'];
  static const List<String> priorities = ['low', 'medium', 'high', 'urgent'];

  String get statusLabel {
    switch (status) {
      case 'todo':
        return 'Cần làm';
      case 'in_progress':
        return 'Đang làm';
      case 'review':
        return 'Kiểm tra';
      case 'done':
        return 'Hoàn thành';
      default:
        return status;
    }
  }

  String get priorityLabel {
    switch (priority) {
      case 'low':
        return 'Thấp';
      case 'medium':
        return 'Trung bình';
      case 'high':
        return 'Cao';
      case 'urgent':
        return 'Gấp';
      default:
        return priority;
    }
  }

  bool get isOverdue {
    if (status == 'done' || dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  bool get isCompleted => status == 'done';
}
