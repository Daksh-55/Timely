import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../models/date_model.dart';

class DateCard extends StatelessWidget {
  final ImportantDate date;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleNotification;

  const DateCard({
    super.key,
    required this.date,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleNotification,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Slidable(
        key: ValueKey(date.id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            if (onEdit != null)
              SlidableAction(
                onPressed: (_) => onEdit?.call(),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                icon: Icons.edit_rounded,
                label: 'Edit',
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            if (onDelete != null)
              SlidableAction(
                onPressed: (_) => onDelete?.call(),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete_rounded,
                label: 'Delete',
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
          ],
        ),
        child: Card(
          margin: EdgeInsets.zero,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Date indicator
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _getIndicatorColor(theme),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('MMM').format(date.date),
                          style: TextStyle(
                            color: _getIndicatorTextColor(theme),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          DateFormat('dd').format(date.date),
                          style: TextStyle(
                            color: _getIndicatorTextColor(theme),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Date info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          date.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (date.description?.isNotEmpty == true) ...[
                          Text(
                            date.description!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                        ],
                        Row(
                          children: [
                            Icon(
                              _getTimeIcon(),
                              size: 16,
                              color: _getTimeColor(theme),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              date.timeUntilText,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: _getTimeColor(theme),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Notification indicator and toggle
                  Column(
                    children: [
                      GestureDetector(
                        onTap: onToggleNotification,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: date.isNotificationEnabled 
                                ? theme.primaryColor.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            date.isNotificationEnabled 
                                ? Icons.notifications_active_rounded
                                : Icons.notifications_off_rounded,
                            size: 20,
                            color: date.isNotificationEnabled 
                                ? theme.primaryColor
                                : Colors.grey,
                          ),
                        ),
                      ),
                      if (date.daysUntil >= 0) ...[
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('yyyy').format(date.date),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getMonthAbbr(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[date.month - 1];
  }

  Color _getIndicatorColor(ThemeData theme) {
    if (date.isPassed) {
      return Colors.grey[300]!;
    } else if (date.isToday) {
      return Colors.green;
    } else if (date.daysUntil <= 7) {
      return Colors.orange;
    } else {
      return theme.primaryColor;
    }
  }

  Color _getIndicatorTextColor(ThemeData theme) {
    if (date.isPassed) {
      return Colors.grey[600]!;
    } else {
      return Colors.white;
    }
  }

  IconData _getTimeIcon() {
    if (date.isPassed) {
      return Icons.history_rounded;
    } else if (date.isToday) {
      return Icons.today_rounded;
    } else {
      return Icons.schedule_rounded;
    }
  }

  Color _getTimeColor(ThemeData theme) {
    if (date.isPassed) {
      return Colors.grey[500]!;
    } else if (date.isToday) {
      return Colors.green;
    } else if (date.daysUntil <= 7) {
      return Colors.orange;
    } else {
      return theme.primaryColor;
    }
  }
}