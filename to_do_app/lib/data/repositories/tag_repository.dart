import '../../core/network/api_client.dart';
import '../datasources/local_data_store.dart';
import '../models/tag_model.dart';
import '../models/task_model.dart';

abstract class TagRepository {
  Future<List<TagModel>> fetchTags();

  Future<TagModel> createTag(String label);

  /// Full replace of a task's tags.
  Future<TaskModel> syncTaskTags(String taskId, List<String> tagIds);
}

class ApiTagRepository implements TagRepository {
  ApiTagRepository(this._api);
  final ApiClient _api;

  @override
  Future<List<TagModel>> fetchTags() async {
    final data = await _api.get('/tags') as List;
    return data.map((t) => TagModel.fromJson(t as Map<String, dynamic>)).toList();
  }

  @override
  Future<TagModel> createTag(String label) async {
    final data = await _api.post('/tags', data: {'label': label}) as Map<String, dynamic>;
    return TagModel.fromJson(data);
  }

  @override
  Future<TaskModel> syncTaskTags(String taskId, List<String> tagIds) async {
    final data = await _api.put('/tasks/$taskId/tags', data: {
      'tag_ids': tagIds.map(int.parse).toList(),
    }) as Map<String, dynamic>;
    return TaskModel.fromJson(data);
  }
}

class MockTagRepository implements TagRepository {
  final LocalDataStore _store = LocalDataStore.instance;

  @override
  Future<List<TagModel>> fetchTags() async => List.unmodifiable(_store.tags);

  @override
  Future<TagModel> createTag(String label) async {
    final existing = _store.tags.where((t) => t.label.toLowerCase() == label.toLowerCase());
    if (existing.isNotEmpty) return existing.first;
    final tag = TagModel(id: 'tag${DateTime.now().millisecondsSinceEpoch}', label: label);
    _store.tags = [..._store.tags, tag];
    return tag;
  }

  @override
  Future<TaskModel> syncTaskTags(String taskId, List<String> tagIds) async {
    final selected = _store.tags.where((t) => tagIds.contains(t.id)).toList();
    final task = _store.tasks.firstWhere((t) => t.id == taskId);
    final updated = task.copyWith(tags: selected);
    _store.tasks = _store.tasks.map((t) => t.id == taskId ? updated : t).toList();
    return updated;
  }
}
