// lib/providers/providers.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/project_model.dart';
import '../data/models/task_model.dart';
import '../data/models/profile_model.dart';
import '../data/services/supabase_service.dart';

// ─── SERVICE ────────────────────────────────────────────────
final supabaseServiceProvider = Provider((ref) => SupabaseService());

// ─── AUTH ────────────────────────────────────────────────────
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseServiceProvider).authStream;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull?.session?.user;
});

// ─── THEME ───────────────────────────────────────────────────
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, bool>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<bool> {
  ThemeModeNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('dark_mode') ?? false;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', state);
  }
}

// ─── LANGUAGE ─────────────────────────────────────────────────
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en')) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'en';
    state = Locale(languageCode);
  }

  Future<void> setLocale(String languageCode) async {
    state = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
  }
}

// ─── NOTIFICATIONS ────────────────────────────────────────────
final notificationsEnabledProvider = StateNotifierProvider<NotificationsNotifier, bool>((ref) {
  return NotificationsNotifier();
});

class NotificationsNotifier extends StateNotifier<bool> {
  NotificationsNotifier() : super(true) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('notifications_enabled') ?? true;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', state);
  }
}


// ─── SINGLE PROJECT ──────────────────────────────────────────
final projectProvider = FutureProvider.family<ProjectModel?, String>((ref, projectId) async {
  return ref.read(supabaseServiceProvider).getProjectById(projectId);
});

final canEditProjectProvider = Provider.family<bool, String>((ref, projectId) {
  final user = ref.watch(currentUserProvider);
  final projects = ref.watch(projectsProvider).valueOrNull ?? [];
  final project = projects.where((p) => p.id == projectId).firstOrNull;
  if (user == null || project == null) return false;
  return project.ownerId == user.id || project.memberIds.contains(user.id);
});

// ─── LOGOUT ──────────────────────────────────────────────────
final logoutProvider = Provider((ref) => LogoutService(ref));

class LogoutService {
  final Ref _ref;
  LogoutService(this._ref);

  Future<void> logout() async {
    await _ref.read(supabaseServiceProvider).signOut();

    _ref.invalidate(profileProvider);
    _ref.invalidate(projectsProvider);
    _ref.invalidate(tasksProvider);
    _ref.invalidate(selectedProjectIdProvider);
    _ref.invalidate(currentUserProvider);
  }
}
// ─── PROFILE ─────────────────────────────────────────────────
final profileProvider = FutureProvider<ProfileModel?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ref.read(supabaseServiceProvider).getProfile(user.id);
});

// ─── USER PROFILES ───────────────────────────────────────────
final userProfileProvider = FutureProvider.family<ProfileModel?, String>((ref, userId) async {
  return ref.read(supabaseServiceProvider).getProfile(userId);
});

// ─── PROJECTS ─────────────────────────────────────────────────
final projectsProvider = AsyncNotifierProvider<ProjectsNotifier, List<ProjectModel>>(
  ProjectsNotifier.new,
);

class ProjectsNotifier extends AsyncNotifier<List<ProjectModel>> {
  @override
  Future<List<ProjectModel>> build() async {
    return ref.read(supabaseServiceProvider).getProjects();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(supabaseServiceProvider).getProjects(),
    );
  }

  Future<void> create(String name, String desc, String color) async {
    final user = ref.read(currentUserProvider)!;
    await ref.read(supabaseServiceProvider).createProject({
      'name': name,
      'description': desc,
      'owner_id': user.id,
      'color': color,
      'member_ids': <String>[],
    });
    await refresh();
  }

  Future<void> delete(String id) async {
    await ref.read(supabaseServiceProvider).deleteProject(id);
    await refresh();
  }
}

// ─── TASKS ───────────────────────────────────────────────────
final selectedProjectIdProvider = StateProvider<String?>((ref) => null);

final tasksProvider = AsyncNotifierProvider<TasksNotifier, List<TaskModel>>(
  TasksNotifier.new,
);

class TasksNotifier extends AsyncNotifier<List<TaskModel>> {
  @override
  Future<List<TaskModel>> build() async {
    final projectId = ref.watch(selectedProjectIdProvider);
    if (projectId == null) {
      return ref.read(supabaseServiceProvider).getMyTasks();
    }
    return ref.read(supabaseServiceProvider).getTasks(projectId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final projectId = ref.read(selectedProjectIdProvider);
    state = await AsyncValue.guard(() async {
      if (projectId == null) {
        return ref.read(supabaseServiceProvider).getMyTasks();
      }
      return ref.read(supabaseServiceProvider).getTasks(projectId);
    });
  }

  Future<void> create(Map<String, dynamic> data) async {
    await ref.read(supabaseServiceProvider).createTask(data);
    await refresh();
  }

  Future<void> updateStatus(String id, String status) async {
    await ref.read(supabaseServiceProvider).updateTask(id, {'status': status});
    await refresh();
  }

  Future<void> editTask(String id, Map<String, dynamic> data) async {
    await ref.read(supabaseServiceProvider).updateTask(id, data);
    await refresh();
  }

  Future<void> delete(String id) async {
    await ref.read(supabaseServiceProvider).deleteTask(id);
    await refresh();
  }
}