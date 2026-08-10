import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/task.dart';
import '../../utils/constants.dart';
import '../../widgets/stats_card.dart';
import '../../widgets/task_card.dart';
import '../tasks/task_list_screen.dart';
import '../tasks/task_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic> _stats = {};
  bool _loadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _loadingStats = true);
    final provider = context.read<TaskProvider>();
    final stats = await provider.getDashboardStats();
    if (mounted) {
      setState(() {
        _stats = stats;
        _loadingStats = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final tasks = provider.tasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tổng quan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              provider.loadAll();
              _loadStats();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await provider.loadAll();
          await _loadStats();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(context),
              const SizedBox(height: 20),
              _buildStatsGrid(),
              const SizedBox(height: 20),
              _buildStatusChart(),
              const SizedBox(height: 20),
              _buildRecentTasks(context, tasks),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Chào buổi sáng';
    } else if (hour < 18) {
      greeting = 'Chào buổi chiều';
    } else {
      greeting = 'Chào buổi tối';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            user?.name ?? 'User',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.position ?? '',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildWelcomeStat('Tổng việc', '${_stats['total'] ?? 0}'),
              const SizedBox(width: 24),
              _buildWelcomeStat('Quá hạn', '${_stats['overdue'] ?? 0}', isWarning: true),
              const SizedBox(width: 24),
              _buildWelcomeStat('Hoàn thành', '${_stats['done'] ?? 0}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeStat(String label, String value, {bool isWarning = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: isWarning ? Colors.amber : Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildStatsGrid() {
    final total = _stats['total'] ?? 0;
    final todo = _stats['todo'] ?? 0;
    final inProgress = _stats['in_progress'] ?? 0;
    final review = _stats['review'] ?? 0;
    final done = _stats['done'] ?? 0;
    final overdue = _stats['overdue'] ?? 0;

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        StatsCard(
          label: 'Tổng số',
          value: '$total',
          icon: Icons.assignment,
          color: const Color(0xFF1565C0),
        ),
        StatsCard(
          label: 'Cần làm',
          value: '$todo',
          icon: Icons.radio_button_unchecked,
          color: const Color(AppColors.statusTodo),
        ),
        StatsCard(
          label: 'Đang làm',
          value: '$inProgress',
          icon: Icons.play_circle_outline,
          color: const Color(AppColors.statusInProgress),
        ),
        StatsCard(
          label: 'Kiểm tra',
          value: '$review',
          icon: Icons.rate_review_outlined,
          color: const Color(AppColors.statusReview),
        ),
        StatsCard(
          label: 'Hoàn thành',
          value: '$done',
          icon: Icons.check_circle_outline,
          color: const Color(AppColors.statusDone),
        ),
        StatsCard(
          label: 'Quá hạn',
          value: '$overdue',
          icon: Icons.warning_amber_outlined,
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatusChart() {
    final total = (_stats['total'] as int? ?? 1);
    final todo = (_stats['todo'] as int? ?? 0);
    final inProgress = (_stats['in_progress'] as int? ?? 0);
    final review = (_stats['review'] as int? ?? 0);
    final done = (_stats['done'] as int? ?? 0);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Phân bố trạng thái',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildProgressBar('Cần làm', todo, total, const Color(AppColors.statusTodo)),
            _buildProgressBar('Đang làm', inProgress, total, const Color(AppColors.statusInProgress)),
            _buildProgressBar('Kiểm tra', review, total, const Color(AppColors.statusReview)),
            _buildProgressBar('Hoàn thành', done, total, const Color(AppColors.statusDone)),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(String label, int count, int total, Color color) {
    final fraction = total > 0 ? count / total : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 13)),
              Text('$count', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTasks(BuildContext context, List<MarketingTask> tasks) {
    final provider = context.watch<TaskProvider>();
    final recentTasks = tasks.where((t) => !t.isCompleted).take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Công việc gần đây',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TaskListScreen()),
                );
              },
              child: const Text('Xem tất cả'),
            ),
          ],
        ),
        if (recentTasks.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(Icons.check_circle_outline, size: 48, color: Colors.green.shade300),
                const SizedBox(height: 8),
                Text('Tất cả công việc đã hoàn thành!',
                    style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          )
        else
          ...recentTasks.map((task) => TaskCard(
                task: task,
                onTap: () {
                  provider.selectTask(task.id!);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TaskDetailScreen(),
                    ),
                  );
                },
              )),
      ],
    );
  }
}
