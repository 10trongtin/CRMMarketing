import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../models/task.dart';
import '../../utils/constants.dart';
import '../../utils/date_utils.dart';

class TaskFormScreen extends StatefulWidget {
  final MarketingTask? task;

  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _status;
  late String _priority;
  int? _assigneeId;
  int? _projectId;
  DateTime? _startDate;
  DateTime? _dueDate;
  late int _progress;
  bool _isSaving = false;

  bool get isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(text: task?.description ?? '');
    _status = task?.status ?? 'todo';
    _priority = task?.priority ?? 'medium';
    _assigneeId = task?.assigneeId;
    _projectId = task?.projectId;
    _startDate = task?.startDate;
    _dueDate = task?.dueDate;
    _progress = task?.progress ?? 0;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final provider = context.read<TaskProvider>();
    final task = MarketingTask(
      id: widget.task?.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      status: _status,
      priority: _priority,
      assigneeId: _assigneeId,
      projectId: _projectId,
      startDate: _startDate,
      dueDate: _dueDate,
      progress: _progress,
      createdAt: widget.task?.createdAt,
    );

    if (isEditing) {
      await provider.updateTask(task);
    } else {
      await provider.addTask(task);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _pickDate(bool isStart) async {
    final initial = isStart ? _startDate : _dueDate;
    final date = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      locale: const Locale('vi', 'VN'),
    );
    if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
        } else {
          _dueDate = date;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final employees = provider.employees;
    final projects = provider.projects;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Sửa công việc' : 'Thêm công việc'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tiêu đề';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                minLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _priority,
                decoration: const InputDecoration(
                  labelText: 'Mức ưu tiên',
                  prefixIcon: Icon(Icons.flag),
                ),
                items: MarketingTask.priorities.map((p) {
                  return DropdownMenuItem(
                    value: p,
                    child: _buildPriorityItem(p),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _priority = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _assigneeId,
                decoration: const InputDecoration(
                  labelText: 'Người thực hiện',
                  prefixIcon: Icon(Icons.person),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Chưa phân công')),
                  ...employees.map((e) => DropdownMenuItem(
                        value: e.id,
                        child: Text(e.name),
                      )),
                ],
                onChanged: (value) => setState(() => _assigneeId = value),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _projectId,
                decoration: const InputDecoration(
                  labelText: 'Dự án',
                  prefixIcon: Icon(Icons.folder),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Không thuộc dự án')),
                  ...projects.map((p) => DropdownMenuItem(
                        value: p.id,
                        child: Text(p.name),
                      )),
                ],
                onChanged: (value) => setState(() => _projectId = value),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDateField(
                      label: 'Ngày bắt đầu',
                      value: _startDate,
                      onTap: () => _pickDate(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDateField(
                      label: 'Hạn hoàn thành',
                      value: _dueDate,
                      onTap: () => _pickDate(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Trạng thái',
                  prefixIcon: Icon(Icons.radio_button_checked),
                ),
                items: MarketingTask.statuses.map((s) {
                  return DropdownMenuItem(
                    value: s,
                    child: _buildStatusItem(s),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _status = value!),
              ),
              const SizedBox(height: 16),
              if (isEditing) ...[
                Text('Tiến độ: $_progress%', style: const TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Slider(
                  value: _progress.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 20,
                  label: '$_progress%',
                  onChanged: (value) => setState(() => _progress = value.toInt()),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(isEditing ? 'Cập nhật' : 'Thêm mới'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField({required String label, DateTime? value, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  value != null ? AppDateUtils.formatDate(value) : 'Chọn ngày',
                  style: TextStyle(
                    color: value != null ? Colors.black : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityItem(String priority) {
    Color color;
    String label;
    switch (priority) {
      case 'low':
        color = const Color(AppColors.priorityLow);
        label = 'Thấp';
        break;
      case 'medium':
        color = const Color(AppColors.priorityMedium);
        label = 'Trung bình';
        break;
      case 'high':
        color = const Color(AppColors.priorityHigh);
        label = 'Cao';
        break;
      case 'urgent':
        color = const Color(AppColors.priorityUrgent);
        label = 'Gấp';
        break;
      default:
        color = Colors.grey;
        label = priority;
    }
    return Row(
      children: [
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  Widget _buildStatusItem(String status) {
    String label;
    switch (status) {
      case 'todo': label = 'Cần làm'; break;
      case 'in_progress': label = 'Đang làm'; break;
      case 'review': label = 'Kiểm tra'; break;
      case 'done': label = 'Hoàn thành'; break;
      default: label = status;
    }
    return Text(label);
  }
}
