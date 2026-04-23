// lib/presentation/projects/project_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/l10n/app_localizations.dart';

import '../../providers/providers.dart';
import '../widgets/task_card.dart';

class ProjectDetailScreen extends ConsumerWidget {
  final String projectId;
  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Set selected project so tasks provider loads the right tasks
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedProjectIdProvider.notifier).state = projectId;
    });

    final projectsAsync = ref.watch(projectsProvider);
    final tasksAsync = ref.watch(tasksProvider);
    final canEdit = ref.watch(canEditProjectProvider(projectId));

    final project = projectsAsync.valueOrNull?.firstWhere(
      (p) => p.id == projectId,
      orElse: () => throw Exception('Not found'),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(project?.name ?? 'Project'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(tasksProvider.notifier).refresh(),
          ),
        ],
      ),
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (tasks) {
          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined,
                      size: 80,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context)!.noTasksYet,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: () => context
                        .push('/task-form', extra: {'projectId': projectId}),
                    icon: const Icon(Icons.add),
                    label: Text(AppLocalizations.of(context)!.addFirstTask),
                  ),
                ],
              ),
            );
          }

          final statuses = ['Todo', 'In Progress', 'Review', 'Done'];

          return DefaultTabController(
            length: statuses.length,
            child: Column(
              children: [
                // Summary row
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      _StatChip(
                          label: 'Total',
                          count: tasks.length,
                          color: Colors.grey),
                      const SizedBox(width: 8),
                      _StatChip(
                          label: 'Done',
                          count: tasks.where((t) => t.status == 'Done').length,
                          color: Colors.green),
                      const SizedBox(width: 8),
                      _StatChip(
                          label: 'Overdue',
                          count: tasks
                              .where((t) =>
                                  t.dueDate != null &&
                                  t.dueDate!.isBefore(DateTime.now()) &&
                                  t.status != 'Done')
                              .length,
                          color: Colors.red),
                    ],
                  ),
                ),

                // Progress bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: tasks.isEmpty
                          ? 0
                          : tasks.where((t) => t.status == 'Done').length /
                              tasks.length,
                      minHeight: 8,
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.15),
                    ),
                  ),
                ),

                TabBar(
                  isScrollable: true,
                  tabs: statuses
                      .map((s) => Tab(
                            text:
                                '$s (${tasks.where((t) => t.status == s).length})',
                          ))
                      .toList(),
                ),
                Expanded(
                  child: TabBarView(
                    children: statuses.map((status) {
                      final filtered =
                          tasks.where((t) => t.status == status).toList();
                      if (filtered.isEmpty) {
                        return Center(
                          child: Text('No $status tasks',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.4))),
                        );
                      }
                      return RefreshIndicator(
                        onRefresh: () =>
                            ref.read(tasksProvider.notifier).refresh(),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) => Consumer(
                            builder: (context, ref, _) {
                              final assignedProfile =
                                  filtered[i].assignedTo != null
                                      ? ref
                                          .watch(userProfileProvider(
                                              filtered[i].assignedTo!))
                                          .valueOrNull
                                      : null;
                              return TaskCard(
                                task: filtered[i],
                                assignedUserName: assignedProfile?.displayName,
                                onTap: canEdit
                                    ? () => context.push('/task-form', extra: {
                                          'task': filtered[i],
                                          'projectId': projectId,
                                        })
                                    : null, // no navigation for view-only users
                                onStatusChange: canEdit
                                    ? (s) => ref
                                        .read(tasksProvider.notifier)
                                        .updateStatus(filtered[i].id, s)
                                    : null,
                                onDelete: canEdit
                                    ? () => ref
                                        .read(tasksProvider.notifier)
                                        .delete(filtered[i].id)
                                    : null,
                              );
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            context.push('/task-form', extra: {'projectId': projectId}),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatChip(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $count',
        style:
            TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }
}
