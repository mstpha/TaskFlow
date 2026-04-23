// lib/presentation/tasks/tasks_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/data/models/project_model.dart';
import 'package:taskflow/data/models/task_model.dart';
import 'package:taskflow/l10n/app_localizations.dart';

import '../../providers/providers.dart';
import '../widgets/task_card.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(selectedProjectIdProvider.notifier).state = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider);
    final profile = ref.watch(profileProvider).valueOrNull;
    final projects = ref.watch(projectsProvider).valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${AppLocalizations.of(context)!.tasks}, ${profile?.displayName ?? 'there'} 👋',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
            Text(AppLocalizations.of(context)!.tasks, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          Consumer(builder: (_, ref, __) {
            final isDark = ref.watch(themeModeProvider);
            return IconButton(
              icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
              onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
            );
          }),
        ],
      ),
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (tasks) {
          final overdue = tasks.where((t) => t.dueDate != null && t.dueDate!.isBefore(DateTime.now()) && t.status != 'Done').length;
          return DefaultTabController(
            length: 4,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Material(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(AppLocalizations.of(context)!.tasks, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _StatCard(label: AppLocalizations.of(context)!.tasks, value: '${tasks.length}'),
                              const SizedBox(width: 12),
                              _StatCard(label: 'Open', value: '${tasks.where((t) => t.status != 'Done').length}'),
                              const SizedBox(width: 12),
                              _StatCard(label: 'Overdue', value: '$overdue', color: Colors.red),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                TabBar(
                  tabs: [
                    Tab(text: AppLocalizations.of(context)!.status),
                    const Tab(text: 'In Progress'),
                    const Tab(text: 'Review'),
                    const Tab(text: 'Done'),
                  ],
                  labelColor: Theme.of(context).colorScheme.primary,
                  indicatorColor: Theme.of(context).colorScheme.primary,
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildTaskList(context, 'Todo', tasks.where((t) => t.status == 'Todo').toList(), projects),
                      _buildTaskList(context, 'In Progress', tasks.where((t) => t.status == 'In Progress').toList(), projects),
                      _buildTaskList(context, 'Review', tasks.where((t) => t.status == 'Review').toList(), projects),
                      _buildTaskList(context, 'Done', tasks.where((t) => t.status == 'Done').toList(), projects),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/task-form'),
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context)!.newTask),
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, String status, List<TaskModel> tasks, List<ProjectModel> projects) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withValues(alpha:0.3),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noTasksYet,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6),
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(tasksProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
children: tasks.map((task) => Consumer(
  builder: (context, ref, _) {
    final assignedProfile = task.assignedTo != null
        ? ref.watch(userProfileProvider(task.assignedTo!)).valueOrNull
        : null;

    final localProject = projects
        .where((p) => p.id == task.projectId)
        .firstOrNull;

    final fetchedProjectName = localProject == null && task.projectId != null
        ? ref.watch(projectProvider(task.projectId!)).valueOrNull?.name
        : null;

    final projectName = localProject?.name ?? fetchedProjectName;

    return TaskCard(
      task: task,
      projectName: projectName,
      assignedUserName: assignedProfile?.displayName,
      onTap: () => context.push('/task-form',
          extra: {'task': task, 'projectId': task.projectId}),
      onStatusChange: (s) =>
          ref.read(tasksProvider.notifier).updateStatus(task.id, s),
      onDelete: () =>
          ref.read(tasksProvider.notifier).delete(task.id),
    );
  },
)).toList(),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha:0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color.withValues(alpha:0.85),
                    )),
            const SizedBox(height: 6),
            Text(value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    )),
          ],
        ),
      ),
    );
  }
}