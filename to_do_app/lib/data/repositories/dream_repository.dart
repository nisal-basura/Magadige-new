import '../../core/network/api_client.dart';
import '../datasources/local_data_store.dart';
import '../models/dream_model.dart';

abstract class DreamRepository {
  Future<List<DreamModel>> fetchDreams();

  Future<DreamModel> createDream(DreamModel dream);

  Future<DreamModel> updateDream(DreamModel dream);

  Future<void> deleteDream(String id);
}

class ApiDreamRepository implements DreamRepository {
  ApiDreamRepository(this._api);
  final ApiClient _api;

  @override
  Future<List<DreamModel>> fetchDreams() async {
    final items = await _api.getAllPages('/dreams');
    return items.map(DreamModel.fromJson).toList();
  }

  @override
  Future<DreamModel> createDream(DreamModel dream) async {
    final data = await _api.post('/dreams', data: dream.toRequestJson()) as Map<String, dynamic>;
    return DreamModel.fromJson(data);
  }

  @override
  Future<DreamModel> updateDream(DreamModel dream) async {
    final data = await _api.put('/dreams/${dream.id}', data: dream.toRequestJson()) as Map<String, dynamic>;
    return DreamModel.fromJson(data);
  }

  @override
  Future<void> deleteDream(String id) async {
    await _api.delete('/dreams/$id');
  }
}

class MockDreamRepository implements DreamRepository {
  final LocalDataStore _store = LocalDataStore.instance;

  @override
  Future<List<DreamModel>> fetchDreams() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_store.dreams);
  }

  @override
  Future<DreamModel> createDream(DreamModel dream) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _store.dreams = [..._store.dreams, dream];
    return dream;
  }

  @override
  Future<DreamModel> updateDream(DreamModel dream) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _store.dreams = _store.dreams.map((d) => d.id == dream.id ? dream : d).toList();
    return dream;
  }

  @override
  Future<void> deleteDream(String id) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _store.dreams = _store.dreams.where((d) => d.id != id).toList();
  }
}
