class Employee {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final String position;
  final String? avatar;
  final DateTime? createdAt;

  Employee({
    this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.position = '',
    this.avatar,
    this.createdAt,
  });

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      position: map['position'] as String? ?? '',
      avatar: map['avatar'] as String?,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'position': position,
      'avatar': avatar,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Employee copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? position,
    String? avatar,
    DateTime? createdAt,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      position: position ?? this.position,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
