import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/task.dart';
import '../../widgets/task_card.dart';
import '../../widgets/empty_state.dart';
import 'task_detail_screen.dart';
import 'task_form_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _searchController = TextEditingController();
  bool _showSearch = false;
  String _viewFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadAll();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final tasks = provider.filteredTasks;

    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm...',
                  hintStyle: TextStyle(color: Colors.white60),
                  border: InputBorder.none,
                  fillColor: Colors.transparent,
                  filled: true,
                ),
                onChanged: (value) => provider.setSearchQuery(value),
              )
            : const Text('Công việc'),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  provider.setSearchQuery('');
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterOptions(context, provider),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusTabs(provider),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : tasks.isEmpty
                    ? EmptyState(
                        icon: Icons.assignment_outlined,
                        title: 'Chưa có công việc nào',
                        subtitle: 'Nhấn nút + để thêm công việc mới',
                        actionLabel: 'Thêm công việc',
                        onAction: () => _addTask(context),
                      )
                    : RefreshIndicator(
                        onRefresh: () => provider.loadAll(),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 8, bottom: 80),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return TaskCard(
                              task: task,
                              onTap: () {
                                provider.selectTask(task.id!);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const TaskDetailScreen(),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTask(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatusTabs(TaskProvider provider) {
    final statuses = ['all', 'todo', 'in_progress', 'review', 'done'];
    final labels = ['Tất cả', 'Cần làm', 'Đang làm', 'Kiểm tra', 'Xong'];

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: List.generate(statuses.length, (index) {
            final isSelected = provider.statusFilter == statuses[index];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(labels[index]),
                selected: isSelected,
                onSelected: (_) => provider.setStatusFilter(statuses[index]),
                selectedColor: const Color(0xFF1565C0),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                backgroundColor: Colors.grey.shade100,
                side: BorderSide.none,
              ),
            );
          }),
        ),
      ),
    );
  }

  void _showFilterOptions(BuildContext context, TaskProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Lọc theo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Người thực hiện', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildEmployeeChip(null, 'Tất cả', provider),
                    ...provider.employees.map((e) => _buildEmployeeChip(e.id, e.name, provider)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmployeeChip(int? id, String label, TaskProvider provider) {
    final isSelected = provider.currentEmployeeId == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          provider.setCurrentEmployee(isSelected ? null : id);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _addTask(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TaskFormScreen()),
    );
  }
}
