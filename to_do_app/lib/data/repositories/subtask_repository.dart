import '../../core/network/api_client.dart';
import '../datasources/local_data_store.dart';
import '../models/subtask_model.dart';

abstract class SubtaskRepository {
  Future<List<SubtaskModel>> fetchSubtasks(String taskId);

  Future<SubtaskModel> addSubtask(String taskId, String title);

  Future<SubtaskModel> updateSubtask(String id, {String? title, bool? isDone});

  Future<void> deleteSubtask(String id);

  Future<List<SubtaskModel>> reorder(String taskId, List<String> orderedIds);
}

class ApiSubtaskRepository implements SubtaskRepository {
  ApiSubtaskRepository(this._api);
  final ApiClient _api;

  @override
  Future<List<SubtaskModel>> fetchSubtasks(String taskId) async {
    final data = await _api.get('/tasks/$taskId/subtasks') as List;
    return data.map((s) => SubtaskModel.fromJson(s as Map<String, dynamic>)).toList();
  }

  @override
  Future<SubtaskModel> addSubtask(String taskId, String title) async {
    final data = await _api.post('/tasks/$taskId/subtasks', data: {'title': title}) as Map<String, dynamic>;
    return SubtaskModel.fromJson(data);
  }

  @override
  Future<SubtaskModel> updateSubtask(String id, {String? title, bool? isDone}) async {
    final data = await _api.patch('/subtasks/$id', data: {
      if (title != null) 'title': title,
      if (isDone != null) 'is_done': isDone,
    }) as Map<String, dynamic>;
    return SubtaskModel.fromJson(data);
  }

  @override
  Future<void> deleteSubtask(String id) async {
    await _api.delete('/subtasks/$id');
  }

  @override
  Future<List<SubtaskModel>> reorder(String taskId, List<String> orderedIds) async {
    final data = await _api.patch('/tasks/$taskId/subtasks/reorder', data: {
      'subtask_ids': orderedIds.map(int.parse).toList(),
    }) as List;
    return data.map((s) => SubtaskModel.fromJson(s as Map<String, dynamic>)).toList();
  }
}

class MockSubtaskRepository implements SubtaskRepository {
  final LocalDataStore _store = LocalDataStore.instance;

  List<SubtaskModel> get _all => _store.subtasks;
  set _all(List<SubtaskModel> value) => _store.subtasks = value;

  @override
  Future<List<SubtaskModel>> fetchSubtasks(String taskId) async {
    return _all.where((s) => s.taskId == taskId).toList()..sort((a, b) => a.position.compareTo(b.position));
  }

  @override
  Future<SubtaskModel> addSubtask(String taskId, String title) async {
    final next = SubtaskModel(
      id: 'st${DateTime.now().millisecondsSinceEpoch}',
      taskId: taskId,
      title: title,
      position: _all.where((s) => s.taskId == taskId).length,
    );
    _all = [..._all, next];
    return next;
  }

  @override
  Future<SubtaskModel> updateSubtask(String id, {String? title, bool? isDone}) async {
    final updated = _all.firstWhere((s) => s.id == id).copyWith(title: title, isDone: isDone);
    _all = _all.map((s) => s.id == id ? updated : s).toList();
    return updated;
  }

  @override
  Future<void> deleteSubtask(String id) async {
    _all = _all.where((s) => s.id != id).toList();
  }

  @override
  Future<List<SubtaskModel>> reorder(String taskId, List<String> orderedIds) async {
    final byId = {for (final s in _all) s.id: s};
    for (var i = 0; i < orderedIds.length; i++) {
      final s = byId[orderedIds[i]];
      if (s != null) byId[orderedIds[i]] = s.copyWith(position: i);
    }
    _all = byId.values.toList();
    return fetchSubtasks(taskId);
  }
}
