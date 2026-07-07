import '../../core/network/api_client.dart';
import '../datasources/local_data_store.dart';
import '../models/category_model.dart';
import '../models/task_model.dart';

/// Task CRUD contract. Favorite/status/dream changes get their own methods
/// because the backend exposes dedicated `PATCH` endpoints for them rather
/// than expecting a full `PUT` with every field re-sent.
abstract class TaskRepository {
  Future<List<TaskModel>> fetchTasks();

  Future<TaskModel> fetchTask(String id);

  Future<TaskModel> createTask(TaskModel task);

  Future<TaskModel> updateTask(TaskModel task);

  Future<void> deleteTask(String id);

  Future<TaskModel> toggleFavorite(String id);

  Future<TaskModel> setStatus(String id, TaskStatus status);

  Future<TaskModel> setDream(String id, String? dreamId);
}

class ApiTaskRepository implements TaskRepository {
  ApiTaskRepository(this._api);
  final ApiClient _api;

  @override
  Future<List<TaskModel>> fetchTasks() async {
    final items = await _api.getAllPages('/tasks');
    return items.map(TaskModel.fromJson).toList();
  }

  @override
  Future<TaskModel> fetchTask(String id) async {
    final data = await _api.get('/tasks/$id') as Map<String, dynamic>;
    return TaskModel.fromJson(data);
  }

  @override
  Future<TaskModel> createTask(TaskModel task) async {
    final data = await _api.post('/tasks', data: task.toRequestJson()) as Map<String, dynamic>;
    return TaskModel.fromJson(data);
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    final data = await _api.put('/tasks/${task.id}', data: task.toRequestJson()) as Map<String, dynamic>;
    return TaskModel.fromJson(data).mergeInto(task);
  }

  @override
  Future<void> deleteTask(String id) async {
    await _api.delete('/tasks/$id');
  }

  @override
  Future<TaskModel> toggleFavorite(String id) async {
    final data = await _api.patch('/tasks/$id/favorite') as Map<String, dynamic>;
    return TaskModel.fromJson(data);
  }

  @override
  Future<TaskModel> setStatus(String id, TaskStatus status) async {
    final data = await _api.patch('/tasks/$id/status', data: {'status': status.apiValue}) as Map<String, dynamic>;
    return TaskModel.fromJson(data);
  }

  @override
  Future<TaskModel> setDream(String id, String? dreamId) async {
    final data = await _api.patch('/tasks/$id/dream', data: {
      'dream_id': dreamId == null ? null : int.tryParse(dreamId),
    }) as Map<String, dynamic>;
    return TaskModel.fromJson(data);
  }
}

class MockTaskRepository implements TaskRepository {
  final LocalDataStore _store = LocalDataStore.instance;

  @override
  Future<List<TaskModel>> fetchTasks() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_store.tasks);
  }

  @override
  Future<TaskModel> fetchTask(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _store.tasks.firstWhere((t) => t.id == id);
  }

  @override
  Future<TaskModel> createTask(TaskModel task) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _store.tasks = [task, ..._store.tasks];
    return task;
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _store.tasks = _store.tasks.map((t) => t.id == task.id ? task : t).toList();
    return task;
  }

  @override
  Future<void> deleteTask(String id) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _store.tasks = _store.tasks.where((t) => t.id != id).toList();
  }

  @override
  Future<TaskModel> toggleFavorite(String id) async {
    final task = _store.tasks.firstWhere((t) => t.id == id);
    final updated = task.copyWith(favorite: !task.favorite);
    return updateTask(updated);
  }

  @override
  Future<TaskModel> setStatus(String id, TaskStatus status) async {
    final task = _store.tasks.firstWhere((t) => t.id == id);
    final updated = task.copyWith(status: status);
    return updateTask(updated);
  }

  @override
  Future<TaskModel> setDream(String id, String? dreamId) async {
    final task = _store.tasks.firstWhere((t) => t.id == id);
    final updated = TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      category: task.category,
      priority: task.priority,
      status: task.status,
      due: task.due,
      tags: task.tags,
      estimateMinutes: task.estimateMinutes,
      favorite: task.favorite,
      createdAt: task.createdAt,
      subtasks: task.subtasks,
      dreamId: dreamId,
    );
    return updateTask(updated);
  }
}
