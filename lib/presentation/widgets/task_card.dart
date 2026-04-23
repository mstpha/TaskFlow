// lib/presentation/widgets/task_card.dart
import 'package:flutter/material.dart';
import '../../data/models/task_model.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onTap;
  final Function(String)? onStatusChange;
  final VoidCallback? onDelete;
  final String? projectName;
  final String? assignedUserName;
  final bool readOnly;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onStatusChange,
    this.onDelete,
    this.projectName,
    this.assignedUserName,
    this.readOnly = false,
  });

  Color _priorityColor(BuildContext context) {
    return switch (task.priority) {
      'Critical' => Colors.red,
      'High' => Colors.orange,
      'Medium' => Colors.blue,
      _ => Colors.grey,
    };
  }

  Color _statusColor(BuildContext context) {
    return switch (task.status) {
      'Done' => Colors.green,
      'In Progress' => Colors.blue,
      'Review' => Colors.orange,
      _ => Theme.of(context).colorScheme.outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDone = task.status == 'Done';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: readOnly ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _priorityColor(context),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                task.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  decoration: isDone
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: isDone
                                      ? theme.colorScheme.onSurface
                                          .withValues(alpha: 0.5)
                                      : null,
                                ),
                              ),
                            ),
                            if (readOnly)
                              Tooltip(
                                message: 'View only',
                                child: Icon(
                                  Icons.lock_outline,
                                  size: 14,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.4),
                                ),
                              ),
                          ],
                        ),
                        if (task.description != null &&
                            task.description!.isNotEmpty)
                          Text(
                            task.description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        if (projectName != null || assignedUserName != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (projectName != null)
                                  _LabelChip(
                                    label: projectName!,
                                    icon: Icons.folder_open,
                                    color: theme.colorScheme.primary,
                                  ),
                                if (assignedUserName != null)
                                  _LabelChip(
                                    label: assignedUserName!,
                                    icon: Icons.person_outline,
                                    color: theme.colorScheme.secondary,
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Only show delete button if not read-only and callback provided
                  if (!readOnly && onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      onPressed: onDelete,
                      color: theme.colorScheme.error,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  GestureDetector(
                    // Disable status change for read-only
                    onTap: (!readOnly && onStatusChange != null)
                        ? () => _showStatusPicker(context)
                        : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(context).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        // Subtle visual cue that status is not tappable
                        border: readOnly
                            ? Border.all(
                                color: _statusColor(context)
                                    .withValues(alpha: 0.3),
                                width: 1,
                              )
                            : null,
                      ),
                      child: Text(
                        task.status,
                        style: TextStyle(
                          color: _statusColor(context)
                              .withValues(alpha: readOnly ? 0.6 : 1.0),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _priorityColor(context).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      task.priority,
                      style: TextStyle(
                        color: _priorityColor(context),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (task.dueDate != null)
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 12,
                          color: task.dueDate!.isBefore(DateTime.now()) &&
                                  !isDone
                              ? Colors.red
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${task.dueDate!.day}/${task.dueDate!.month}',
                          style: TextStyle(
                            fontSize: 12,
                            color: task.dueDate!.isBefore(DateTime.now()) &&
                                    !isDone
                                ? Colors.red
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStatusPicker(BuildContext context) {
    final statuses = ['Todo', 'In Progress', 'Review', 'Done'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Change Status',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...statuses.map((s) => ListTile(
                  title: Text(s),
                  trailing:
                      s == task.status ? const Icon(Icons.check) : null,
                  onTap: () {
                    Navigator.pop(context);
                    onStatusChange?.call(s);
                  },
                )),
          ],
        ),
      ),
    );
  }
}

class _LabelChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _LabelChip(
      {required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}