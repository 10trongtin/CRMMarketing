import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../models/task.dart';
import '../../utils/constants.dart';
import '../../utils/date_utils.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/priority_badge.dart';
import 'task_form_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final task = provider.selectedTask;

    if (task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết công việc')),
        body: const Center(child: Text('Không tìm thấy công việc')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết công việc'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, task),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(task),
            const SizedBox(height: 20),
            _buildStatusSection(task, provider),
            const SizedBox(height: 20),
            if (task.description.isNotEmpty) _buildSection('Mô tả', task.description),
            const SizedBox(height: 16),
            _buildInfoCards(task),
            const SizedBox(height: 16),
            _buildProgressSection(task, provider),
            const SizedBox(height: 16),
            if (task.project != null) _buildProjectInfo(task),
            const SizedBox(height: 16),
            _buildTimeline(task),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(MarketingTask task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            PriorityBadge(priority: task.priority, fontSize: 12),
            const SizedBox(width: 8),
            StatusBadge(status: task.status, fontSize: 12),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          task.title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStatusSection(MarketingTask task, TaskProvider provider) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cập nhật trạng thái', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: MarketingTask.statuses.map((status) {
                final isActive = task.status == status;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (task.id != null) {
                        provider.updateTaskStatus(task.id!, status);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: isActive ? _getStatusColor(status) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _getStatusIcon(status),
                            size: 20,
                            color: isActive ? Colors.white : Colors.grey,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getShortStatus(status),
                            style: TextStyle(
                              fontSize: 11,
                              color: isActive ? Colors.white : Colors.grey.shade700,
                              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 8),
        Text(content, style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5)),
      ],
    );
  }

  Widget _buildInfoCards(MarketingTask task) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            Icons.person_outline,
            'Người thực hiện',
            task.assignee?.name ?? 'Chưa phân công',
            task.assignee != null ? const Color(0xFF1565C0) : Colors.grey,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            Icons.calendar_today,
            'Hạn hoàn thành',
            task.dueDate != null ? AppDateUtils.formatDate(task.dueDate!) : 'Chưa có',
            task.isOverdue ? Colors.red : const Color(0xFF1565C0),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value, Color color) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(MarketingTask task, TaskProvider provider) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tiến độ', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('${task.progress}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: task.progress / 100,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(
                  task.progress >= 80 ? Colors.green : const Color(0xFF42A5F5),
                ),
                minHeight: 8,
              ),
            ),
            if (task.id != null) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [0, 25, 50, 75, 100].map((p) {
                  return GestureDetector(
                    onTap: () => provider.updateTaskProgress(task.id!, p),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: task.progress == p
                            ? const Color(0xFF1565C0)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$p%',
                        style: TextStyle(
                          color: task.progress == p ? Colors.white : Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProjectInfo(MarketingTask task) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.folder_outlined, color: Color(0xFF1565C0)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Dự án', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(task.project!.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                task.project!.statusLabel,
                style: TextStyle(fontSize: 12, color: Colors.green.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(MarketingTask task) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dòng thời gian', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _buildTimelineItem(
              Icons.add_circle_outline,
              'Được tạo',
              task.createdAt != null ? AppDateUtils.formatDateTime(task.createdAt!) : '',
              isFirst: true,
            ),
            if (task.completedAt != null)
              _buildTimelineItem(
                Icons.check_circle,
                'Hoàn thành',
                AppDateUtils.formatDateTime(task.completedAt!),
                color: Colors.green,
              ),
            if (task.dueDate != null)
              _buildTimelineItem(
                Icons.event,
                'Hạn chót',
                AppDateUtils.formatDate(task.dueDate!),
                color: task.isOverdue ? Colors.red : null,
                isLast: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(IconData icon, String title, String subtitle, {bool isFirst = false, bool isLast = false, Color? color}) {
    final itemColor = color ?? const Color(0xFF1565C0);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              if (!isFirst)
                Container(
                  width: 2,
                  height: 8,
                  color: Colors.grey.shade300,
                ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: itemColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: itemColor),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey.shade300,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, MarketingTask task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa "${task.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              context.read<TaskProvider>().deleteTask(task.id!);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'todo': return const Color(AppColors.statusTodo);
      case 'in_progress': return const Color(AppColors.statusInProgress);
      case 'review': return const Color(AppColors.statusReview);
      case 'done': return const Color(AppColors.statusDone);
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'todo': return Icons.radio_button_unchecked;
      case 'in_progress': return Icons.play_circle_outline;
      case 'review': return Icons.rate_review_outlined;
      case 'done': return Icons.check_circle_outline;
      default: return Icons.help_outline;
    }
  }

  String _getShortStatus(String status) {
    switch (status) {
      case 'todo': return 'Cần làm';
      case 'in_progress': return 'Đang làm';
      case 'review': return 'Kiểm tra';
      case 'done': return 'Xong';
      default: return status;
    }
  }
}
