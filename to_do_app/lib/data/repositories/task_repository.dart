import '../datasources/local_data_store.dart';
import '../models/task_model.dart';

/// Task CRUD contract. An `ApiTaskRepository` implementing this same
/// interface is the only thing needed to switch the app onto a real backend.
abstract class TaskRepository {
  Future<List<TaskModel>> fetchTasks();

  Future<TaskModel> createTask(TaskModel task);

  Future<TaskModel> updateTask(TaskModel task);

  Future<void> deleteTask(String id);
}

class MockTaskRepository implements TaskRepository {
  final LocalDataStore _store = LocalDataStore.instance;

  @override
  Future<List<TaskModel>> fetchTasks() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_store.tasks);
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
}
