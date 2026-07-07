import '../../core/network/api_client.dart';
import '../datasources/local_data_store.dart';
import '../models/category_model.dart';

abstract class CategoryRepository {
  Future<List<CategoryModel>> fetchCategories();
}

class ApiCategoryRepository implements CategoryRepository {
  ApiCategoryRepository(this._api);
  final ApiClient _api;

  @override
  Future<List<CategoryModel>> fetchCategories() async {
    final data = await _api.get('/categories') as List;
    return data.map((c) => CategoryModel.fromJson(c as Map<String, dynamic>)).toList();
  }
}

class MockCategoryRepository implements CategoryRepository {
  @override
  Future<List<CategoryModel>> fetchCategories() async => List.unmodifiable(LocalDataStore.instance.categories);
}
