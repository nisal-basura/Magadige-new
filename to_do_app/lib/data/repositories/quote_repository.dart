import '../../core/network/api_client.dart';
import '../datasources/seed_data.dart';

class QuoteModel {
  final String text;
  final String? author;

  const QuoteModel({required this.text, this.author});

  factory QuoteModel.fromJson(Map<String, dynamic> json) =>
      QuoteModel(text: json['text'] as String, author: json['author'] as String?);
}

abstract class QuoteRepository {
  Future<QuoteModel> getRandom({String? mood});
}

class ApiQuoteRepository implements QuoteRepository {
  ApiQuoteRepository(this._api);
  final ApiClient _api;

  @override
  Future<QuoteModel> getRandom({String? mood}) async {
    final data = await _api.get('/quotes/random', query: mood == null ? null : {'mood': mood}) as Map<String, dynamic>;
    return QuoteModel.fromJson(data);
  }
}

class MockQuoteRepository implements QuoteRepository {
  @override
  Future<QuoteModel> getRandom({String? mood}) async {
    final q = SeedData.quotes[DateTime.now().millisecond % SeedData.quotes.length];
    return QuoteModel(text: q['text']!, author: q['author']);
  }
}
