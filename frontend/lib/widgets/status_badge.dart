import 'package:flutter/material.dart';
import '../utils/constants.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const StatusBadge({super.key, required this.status, this.fontSize = 12});

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: config.color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4),
          Text(
            config.label,
            style: TextStyle(
              color: config.color,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getConfig() {
    switch (status) {
      case 'todo':
        return _StatusConfig(const Color(AppColors.statusTodo), 'Cần làm');
      case 'in_progress':
        return _StatusConfig(const Color(AppColors.statusInProgress), 'Đang làm');
      case 'review':
        return _StatusConfig(const Color(AppColors.statusReview), 'Kiểm tra');
      case 'done':
        return _StatusConfig(const Color(AppColors.statusDone), 'Hoàn thành');
      default:
        return _StatusConfig(Colors.grey, status);
    }
  }
}

class _StatusConfig {
  final Color color;
  final String label;
  _StatusConfig(this.color, this.label);
}
