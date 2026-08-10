import 'package:flutter/material.dart';
import '../utils/constants.dart';

class PriorityBadge extends StatelessWidget {
  final String priority;
  final double fontSize;

  const PriorityBadge({super.key, required this.priority, this.fontSize = 11});

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        config.label,
        style: TextStyle(
          color: config.color,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  _PriorityConfig _getConfig() {
    switch (priority) {
      case 'low':
        return _PriorityConfig(const Color(AppColors.priorityLow), 'Thấp');
      case 'medium':
        return _PriorityConfig(const Color(AppColors.priorityMedium), 'TB');
      case 'high':
        return _PriorityConfig(const Color(AppColors.priorityHigh), 'Cao');
      case 'urgent':
        return _PriorityConfig(const Color(AppColors.priorityUrgent), 'Gấp');
      default:
        return _PriorityConfig(Colors.grey, priority);
    }
  }
}

class _PriorityConfig {
  final Color color;
  final String label;
  _PriorityConfig(this.color, this.label);
}
