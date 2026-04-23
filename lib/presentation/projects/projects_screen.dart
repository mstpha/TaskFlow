// lib/presentation/projects/projects_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/l10n/app_localizations.dart';

import '../../providers/providers.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.projects)),
      body: projectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (projects) {
          if (projects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_outlined, size: 80,
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context)!.noProjectsYet,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  Text(AppLocalizations.of(context)!.tapCreateFirstProject,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(projectsProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: projects.length,
              itemBuilder: (_, i) {
                final p = projects[i];
                final color = Color(int.parse(p.color.replaceAll('#', '0xFF')));
                final canEdit = currentUser != null &&
                    (p.ownerId == currentUser.id || p.memberIds.contains(currentUser.id));

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () => context.push('/projects/${p.id}'),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(Icons.folder_rounded, color: color, size: 28),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(p.name,
                                          style: Theme.of(context).textTheme.titleMedium
                                              ?.copyWith(fontWeight: FontWeight.bold)),
                                    ),
                                    if (!canEdit)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.lock_outline, size: 11,
                                                color: Theme.of(context).colorScheme.outline),
                                            const SizedBox(width: 4),
                                            Text('View only',
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    color: Theme.of(context).colorScheme.outline,
                                                    fontWeight: FontWeight.w600)),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                if (p.description != null && p.description!.isNotEmpty)
                                  Text(p.description!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                                          )),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 6,
                                  children: [
                                    _InfoBadge(label: '${p.memberIds.length + 1} members', icon: Icons.group),
                                    const _InfoBadge(label: 'Tasks in project', icon: Icons.task_alt_rounded),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (canEdit)
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20),
                              color: Theme.of(context).colorScheme.error,
                              onPressed: () => _confirmDelete(context, ref, p.id, p.name),
                            ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right_rounded),
                            onPressed: () => context.push('/projects/${p.id}'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, ref),
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context)!.newProject),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id, String name) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteProject),
        content: Text(AppLocalizations.of(context)!.deleteProjectConfirmation(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(projectsProvider.notifier).delete(id);
              Navigator.of(dialogContext).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  const _InfoBadge({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

void _showCreateDialog(BuildContext context, WidgetRef ref) {
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  String color = '#6366F1';
  final colors = ['#6366F1', '#10B981', '#F59E0B', '#EF4444', '#8B5CF6', '#06B6D4'];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppLocalizations.of(context)!.newProject,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: '${AppLocalizations.of(context)!.title} *')),
            const SizedBox(height: 12),
            TextField(
                controller: descCtrl,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.description)),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.color,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: colors.map((c) {
                final col = Color(int.parse(c.replaceAll('#', '0xFF')));
                return GestureDetector(
                  onTap: () => setState(() => color = c),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: col,
                      shape: BoxShape.circle,
                      border: color == c ? Border.all(color: Colors.white, width: 3) : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty) return;
                await ref.read(projectsProvider.notifier).create(nameCtrl.text, descCtrl.text, color);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(AppLocalizations.of(context)!.createProject),
            ),
          ],
        ),
      ),
    ),
  );
}