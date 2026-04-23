// lib/presentation/widgets/main_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/l10n/app_localizations.dart';

import '../../providers/providers.dart';

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith('/projects')) return 1;
    if (location.startsWith('/profile')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final location = GoRouterState.of(context).matchedLocation;
    final index = _locationToIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          if (i == 0) context.go('/tasks');
          if (i == 1) context.go('/projects');
          if (i == 2) context.go('/profile');
        },
        destinations: [
          NavigationDestination(icon: const Icon(Icons.checklist_rounded), label: AppLocalizations.of(context)!.tasks),
          NavigationDestination(icon: const Icon(Icons.folder_outlined), label: AppLocalizations.of(context)!.projects),
          NavigationDestination(icon: const Icon(Icons.person_outline), label: AppLocalizations.of(context)!.profile),
        ],
      ),
    );
  }
}
