import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/employee.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../utils/constants.dart';
import '../login/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final user = auth.currentUser;

    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cá nhân'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(user),
            const SizedBox(height: 24),
            _buildStatsSummary(taskProvider),
            const SizedBox(height: 24),
            _buildInfoSection(user),
            const SizedBox(height: 24),
            _buildMenuSection(context, auth),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Employee employee) {
    return Column(
      children: [
        CircleAvatar(
          radius: 48,
          backgroundColor: const Color(0xFF1565C0).withOpacity(0.1),
          child: Text(
            employee.initials,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1565C0),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          employee.name,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          employee.position,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildStatsSummary(TaskProvider taskProvider) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatCol('Tổng', '${taskProvider.totalTasks}'),
            Container(width: 1, height: 40, color: Colors.grey.shade200),
            _buildStatCol('Đang làm', '${taskProvider.inProgressTasks}'),
            Container(width: 1, height: 40, color: Colors.grey.shade200),
            _buildStatCol('Xong', '${taskProvider.doneTasks}'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCol(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildInfoSection(Employee employee) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thông tin liên hệ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.email_outlined, employee.email),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.phone_outlined, employee.phone),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.badge_outlined, employee.position),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF1565C0)),
        const SizedBox(width: 12),
        Text(value, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context, AuthProvider auth) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
            onTap: () {
              auth.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
