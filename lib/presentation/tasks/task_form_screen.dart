// lib/presentation/tasks/task_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/l10n/app_localizations.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/task_model.dart';
import '../../data/services/notification_service.dart';
import '../../providers/providers.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  final String? projectId;
  final TaskModel? task;

  const TaskFormScreen({super.key, this.projectId, this.task});

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _status = 'Todo';
  String _priority = 'Medium';
  String? _projectId;
  String? _assignedTo;
  DateTime? _dueDate;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    if (task != null) {
      _titleCtrl.text = task.title;
      _descCtrl.text = task.description ?? '';
      _status = task.status;
      _priority = task.priority;
      _assignedTo = task.assignedTo;
      _dueDate = task.dueDate;
      _projectId = task.projectId;
    } else {
      _projectId = widget.projectId;
    }
  }

  Future<void> _save() async {
    if (_titleCtrl.text.isEmpty) return;
    if (_projectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a project')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final userId = ref.read(currentUserProvider)!.id;
      final data = {
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'project_id': _projectId,
        'created_by': widget.task?.createdBy ?? userId,
        'assigned_to': _assignedTo,
        'status': _status,
        'priority': _priority,
        'due_date': _dueDate?.toIso8601String(),
      };

      if (widget.task != null) {
        await ref.read(tasksProvider.notifier).editTask(widget.task!.id, data);
      } else {
        await ref.read(tasksProvider.notifier).create(data);
        final notificationsEnabled = ref.read(notificationsEnabledProvider);
        if (_dueDate != null && notificationsEnabled) {
          await NotificationService.scheduleTaskReminder(
            id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            taskTitle: _titleCtrl.text,
            dueDate: _dueDate!,
          );
        }
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectsProvider).valueOrNull ?? [];
    final isEdit = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Task' : AppLocalizations.of(context)!.newTask),
        actions: [
          TextButton(
            onPressed: _loading ? null : _save,
            child: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.title),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.description),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Project selector
            DropdownButtonFormField<String>(
              initialValue: _projectId,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.projects),
              items: projects.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
              onChanged: (v) => setState(() => _projectId = v),
            ),
            const SizedBox(height: 12),

            // Status & Priority row
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _status,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.status),
                    items: AppConstants.statuses
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => _status = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _priority,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.priority),
                    items: AppConstants.priorities
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (v) => setState(() => _priority = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Due date
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: Text(_dueDate == null
                  ? AppLocalizations.of(context)!.dueDate
                  : '${AppLocalizations.of(context)!.dueDate}: ${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) setState(() => _dueDate = date);
              },
              trailing: _dueDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _dueDate = null),
                    )
                  : null,
            ),
            const Divider(),

            // Assign to
            const SizedBox(height: 8),
            AssigneeSelector(
              currentAssignee: _assignedTo,
              onAssigned: (id) => setState(() => _assignedTo = id),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }
}

class AssigneeSelector extends ConsumerStatefulWidget {
  final String? currentAssignee;
  final Function(String?) onAssigned;

  const AssigneeSelector({super.key, this.currentAssignee, required this.onAssigned});

  @override
  ConsumerState<AssigneeSelector> createState() => _AssigneeSelectorState();
}

class _AssigneeSelectorState extends ConsumerState<AssigneeSelector> {
  final _searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final selectedProfile = widget.currentAssignee != null
        ? ref.watch(userProfileProvider(widget.currentAssignee!)).valueOrNull
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Assign To', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        if (selectedProfile != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withValues(alpha:0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                leading: CircleAvatar(
                  foregroundColor: Colors.white,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  child: Text(selectedProfile.displayName.isNotEmpty
                      ? selectedProfile.displayName[0].toUpperCase()
                      : '?'),
                ),
                title: Text(selectedProfile.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(selectedProfile.email),
                trailing: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => widget.onAssigned(null),
                ),
              ),
            ),
          ),
        TextField(
          controller: _searchCtrl,
          decoration: InputDecoration(
            labelText: 'Search users',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: widget.currentAssignee != null
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => widget.onAssigned(null),
                  )
                : null,
          ),
          onChanged: (v) => setState(() {}),
        ),
        if (_searchCtrl.text.length > 2)
          FutureBuilder(
            future: ref.read(supabaseServiceProvider).searchUsers(_searchCtrl.text),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const LinearProgressIndicator();
              return Column(
                children: snapshot.data!
                    .map((u) => ListTile(
                          leading: CircleAvatar(child: Text(u.displayName[0].toUpperCase())),
                          title: Text(u.displayName),
                          subtitle: Text(u.email),
                          trailing: widget.currentAssignee == u.id ? const Icon(Icons.check) : null,
                          onTap: () {
                            widget.onAssigned(u.id);
                            _searchCtrl.clear();
                            setState(() {});
                          },
                        ))
                    .toList(),
              );
            },
          ),
      ],
    );
  }
}