class Project {
  final int? id;
  final String name;
  final String description;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;
  final DateTime? createdAt;

  Project({
    this.id,
    required this.name,
    this.description = '',
    this.startDate,
    this.endDate,
    this.status = 'active',
    this.createdAt,
  });

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      startDate: map['start_date'] != null ? DateTime.tryParse(map['start_date'] as String) : null,
      endDate: map['end_date'] != null ? DateTime.tryParse(map['end_date'] as String) : null,
      status: map['status'] as String? ?? 'active',
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'status': status,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Project copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    DateTime? createdAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static const List<String> statuses = ['active', 'completed', 'paused', 'cancelled'];

  String get statusLabel {
    switch (status) {
      case 'active':
        return 'Đang thực hiện';
      case 'completed':
        return 'Hoàn thành';
      case 'paused':
        return 'Tạm dừng';
      case 'cancelled':
        return 'Hủy bỏ';
      default:
        return status;
    }
  }
}
