// lib/presentation/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow/l10n/app_localizations.dart';

import '../../providers/providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final isDark = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);
    final theme = Theme.of(context);

    String languageLabel(String code) {
      return switch (code) {
        'fr' => 'Français',
        'ar' => 'العربية',
        _ => 'English',
      };
    }

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.profile)),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Avatar
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  (profile?.displayName ?? '?')[0].toUpperCase(),
                  style: const TextStyle(fontSize: 40, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                profile?.displayName ?? 'User',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Center(
              child: Text(
                profile?.email ?? '',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Stats
            ref.watch(tasksProvider).when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (tasks) {
                    final userId = ref.read(currentUserProvider)?.id;
                    final myTasks = tasks
                        .where((t) =>
                            t.assignedTo == userId || t.createdBy == userId)
                        .toList();
                    final done =
                        myTasks.where((t) => t.status == 'Done').length;
                    return Row(
                      children: [
                        Expanded(
                            child: _StatCard(
                                label: 'Total Tasks',
                                value: '${myTasks.length}')),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _StatCard(
                                label: 'Completed',
                                value: '$done',
                                color: Colors.green)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            label: 'Pending',
                            value: '${myTasks.length - done}',
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    );
                  },
                ),
            const SizedBox(height: 24),

            // Settings
            _SectionTitle(AppLocalizations.of(context)!.language),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(AppLocalizations.of(context)!.darkMode),
                    secondary: const Icon(Icons.dark_mode_outlined),
                    value: isDark,
                    onChanged: (_) =>
                        ref.read(themeModeProvider.notifier).toggle(),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.language_outlined),
                    title: Text(AppLocalizations.of(context)!.language),
                    subtitle: Text(languageLabel(locale.languageCode)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showLanguagePicker(context, ref),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text(AppLocalizations.of(context)!.notifications),
                    secondary: const Icon(Icons.notifications_outlined),
                    value: notificationsEnabled,
                    onChanged: (_) => ref
                        .read(notificationsEnabledProvider.notifier)
                        .toggle(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const _SectionTitle('Account'),
            Card(
              child: ListTile(
                leading:
                    Icon(Icons.logout_rounded, color: theme.colorScheme.error),
                title: Text(AppLocalizations.of(context)!.signOut,
                    style: TextStyle(color: theme.colorScheme.error)),
                onTap: () => _confirmSignOut(context, ref),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    const languages = [
      {'label': '🇬🇧 English', 'code': 'en'},
      {'label': '🇫🇷 Français', 'code': 'fr'},
      {'label': '🇸🇦 العربية', 'code': 'ar'},
    ];

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
            Text('Select Language',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ...languages.map((lang) => ListTile(
                  title: Text(lang['label'] as String),
                  onTap: () {
                    ref
                        .read(localeProvider.notifier)
                        .setLocale(lang['code'] as String);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

void _confirmSignOut(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(  // <-- use dialogContext here
      title: const Text('Sign Out'),
      content: const Text('Are you sure you want to sign out?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),  // <-- dialogContext
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            Navigator.of(dialogContext).pop();  // <-- dialogContext
            await ref.read(logoutProvider).logout();
            // Router handles navigation automatically
          },
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          child: const Text('Sign Out'),
        ),
      ],
    ),
  );
}
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _StatCard({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 28, fontWeight: FontWeight.bold, color: c)),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6))),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
        ),
      );
}
