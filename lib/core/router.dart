// lib/core/router.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart'; // for ChangeNotifier
import 'package:supabase_flutter/supabase_flutter.dart'; // for AuthState
import '../presentation/auth/login_screen.dart';
import '../presentation/auth/register_screen.dart';
import '../presentation/tasks/tasks_screen.dart';
import '../presentation/tasks/task_form_screen.dart';
import '../presentation/projects/projects_screen.dart';
import '../presentation/projects/project_detail_screen.dart';
import '../presentation/profile/profile_screen.dart';
import '../presentation/widgets/main_shell.dart';
import '../providers/providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Use a notifier that GoRouter can listen to without recreating itself
  final notifier = _RouterNotifier(ref);

  final router = GoRouter(
    initialLocation: '/tasks',
    refreshListenable: notifier,   // GoRouter re-evaluates redirect on auth change
    redirect: (context, state) {
      if (notifier.isLoading) return null;

      final isLoggedIn = notifier.isLoggedIn;
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/tasks';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/tasks', builder: (_, __) => const TasksScreen()),
          GoRoute(path: '/projects', builder: (_, __) => const ProjectsScreen()),
          GoRoute(
            path: '/projects/:id',
            builder: (_, state) =>
                ProjectDetailScreen(projectId: state.pathParameters['id']!),
          ),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),
      GoRoute(
        path: '/task-form',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return TaskFormScreen(
            projectId: extra?['projectId'],
            task: extra?['task'],
          );
        },
      ),
    ],
  );

  // Dispose the notifier when the provider is disposed
  ref.onDispose(notifier.dispose);

  return router;
});

class _RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  bool isLoading = true;
  bool isLoggedIn = false;

  _RouterNotifier(this._ref) {
    // Listen to auth changes and notify GoRouter
    _ref.listen<AsyncValue<AuthState>>(
      authStateProvider,
      (_, next) {
        isLoading = next.isLoading;
        isLoggedIn = next.valueOrNull?.session != null;
        notifyListeners(); // triggers GoRouter.redirect without rebuilding MaterialApp
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}