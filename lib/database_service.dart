import 'package:supabase_flutter/supabase_flutter.dart';

import 'model.dart';

class DatabaseService {
  final SupabaseClient _client;

  DatabaseService(this._client);

  Future<List<Category>> getCategories() async {
    final response = await _client.from('categories').select();
    if (response.isEmpty) {
      return [];
    }
    return response.map((data) => serializers.deserializeWith(Category.serializer, data)).whereType<Category>().toList();
  }

  Future<List<Word>> getWordsByCategory(int categoryId) async {
    final response = await _client
        .from('words')
        .select()
        .eq('category_id', categoryId);
    if (response.isEmpty) {
      return [];
    }
    return response.map((data) => serializers.deserializeWith(Word.serializer, data)).whereType<Word>().toList();
  }

  Future<Player> addPlayer(String name) async {
    final response = await _client.from('players').insert({'name': name}).select();
    return serializers.deserializeWith(Player.serializer, response.first)!;
  }

  Future<void> addScore(Score score) async {
    await _client.from('scores').insert(serializers.serializeWith(Score.serializer, score) as Map<String, dynamic>);
  }

  Future<List<Score>> getScoresByCategory(int categoryId) async {
    final response = await _client
        .from('scores')
        .select('*, players(*)')
        .eq('category_id', categoryId)
        .order('time', ascending: true);
    if (response.isEmpty) {
      return [];
    }
    return response.map((data) => serializers.deserializeWith(Score.serializer, data)).whereType<Score>().toList();
  }
}
