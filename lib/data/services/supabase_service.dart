// lib/data/services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_model.dart';
import '../models/project_model.dart';
import '../models/profile_model.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  // ─── AUTH ───────────────────────────────────────────────
  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStream => _client.auth.onAuthStateChange;

  Future<void> signUp(String email, String password, String fullName) async {
    await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  Future<void> signIn(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // ─── PROFILES ───────────────────────────────────────────
  Future<ProfileModel?> getProfile(String userId) async {
    final res = await _client.from('profiles').select().eq('id', userId).maybeSingle();
    return res != null ? ProfileModel.fromJson(res) : null;
  }

  Future<List<ProfileModel>> searchUsers(String query) async {
    final res = await _client
        .from('profiles')
        .select()
        .ilike('full_name', '%$query%')
        .limit(10);
    return res.map((e) => ProfileModel.fromJson(e)).toList();
  }

  // ─── PROJECTS ───────────────────────────────────────────
Future<List<ProjectModel>> getProjects() async {
  final userId = currentUser!.id;
  
  // Get projects where user is owner or member
  final ownedOrMember = await _client
      .from('projects')
      .select()
      .or('owner_id.eq.$userId,member_ids.cs.{"$userId"}')
      .order('created_at', ascending: false);

  // Get project IDs from tasks assigned to user
  final assignedTasks = await _client
      .from('tasks')
      .select('project_id')
      .eq('assigned_to', userId);

  final assignedProjectIds = assignedTasks
      .map((t) => t['project_id'] as String)
      .toSet();

  // Fetch those extra projects
  final existingIds = ownedOrMember.map((p) => p['id'] as String).toSet();
  final missingIds = assignedProjectIds.difference(existingIds).toList();

  List<Map<String, dynamic>> assignedProjects = [];
  if (missingIds.isNotEmpty) {
    assignedProjects = await _client
        .from('projects')
        .select()
        .inFilter('id', missingIds);
  }

  final all = [...ownedOrMember, ...assignedProjects];
  return all.map((e) => ProjectModel.fromJson(e)).toList();
}

  Future<ProjectModel> createProject(Map<String, dynamic> data) async {
    final res = await _client.from('projects').insert(data).select().single();
    return ProjectModel.fromJson(res);
  }

  Future<void> updateProject(String id, Map<String, dynamic> data) async {
    await _client.from('projects').update(data).eq('id', id);
  }

  Future<void> deleteProject(String id) async {
    await _client.from('projects').delete().eq('id', id);
  }


Future<ProjectModel?> getProjectById(String id) async {
  final res = await _client
      .from('projects')
      .select()
      .eq('id', id)
      .maybeSingle();
  return res != null ? ProjectModel.fromJson(res) : null;
}
  // ─── TASKS ──────────────────────────────────────────────
  Future<List<TaskModel>> getTasks(String projectId) async {
    final res = await _client
        .from('tasks')
        .select()
        .eq('project_id', projectId)
        .order('created_at', ascending: false);
    return res.map((e) => TaskModel.fromJson(e)).toList();
  }

  Future<List<TaskModel>> getMyTasks() async {
    final userId = currentUser!.id;
    final res = await _client
        .from('tasks')
        .select()
        .or('created_by.eq.$userId,assigned_to.eq.$userId')
        .order('created_at', ascending: false);
    return res.map((e) => TaskModel.fromJson(e)).toList();
  }

  Future<TaskModel> createTask(Map<String, dynamic> data) async {
    final res = await _client.from('tasks').insert(data).select().single();
    return TaskModel.fromJson(res);
  }

  Future<void> updateTask(String id, Map<String, dynamic> data) async {
    await _client.from('tasks').update(data).eq('id', id);
  }

  Future<void> deleteTask(String id) async {
    await _client.from('tasks').delete().eq('id', id);
  }
}
