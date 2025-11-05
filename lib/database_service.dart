import 'package:built_value/serializer.dart';
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
    return response.map((data) => Category((b) => b
      ..id = data['id']
      ..name = data['name'])).toList();
  }

  Future<List<Word>> getWords() async {
    final response = await _client.from('words').select();
    if (response.isEmpty) {
      return [];
    }
    return response.map((data) => Word((b) => b
      ..id = data['id']
      ..word = data['word']
      ..clue = data['clue']
      ..categoryId = data['category_id'])).toList();
  }

  Future<List<Word>> getWordsByCategory(int categoryId) async {
    final response = await _client
        .from('words')
        .select()
        .eq('category_id', categoryId);
    if (response.isEmpty) {
      return [];
    }
    return response.map((data) => Word((b) => b
      ..id = data['id']
      ..word = data['word']
      ..clue = data['clue']
      ..categoryId = data['category_id'])).toList();
  }

  Future<Player?> getPlayerByName(String name) async {
    final response = await _client.from('players').select().eq('name', name);
    if (response.isEmpty) {
      return null;
    }
    final data = response.first;
    return Player((b) => b
      ..id = data['id']
      ..name = data['name']);
  }

  Future<Player?> getPlayerById(int id) async {
    final response = await _client.from('players').select().eq('id', id);
    if (response.isEmpty) {
      return null;
    }
    final data = response.first;
    return Player((b) => b
      ..id = data['id']
      ..name = data['name']);
  }

  Future<Player> addPlayer(String name) async {
    final response = await _client.from('players').insert({'name': name}).select();
    final data = response.first;
    return Player((b) => b
      ..id = data['id']
      ..name = data['name']);
  }

  Future<void> addScore(Score score) async {
    await _client.from('scores').insert([
      {
        'player_id': score.playerId,
        'time': score.time,
        'category_id': score.categoryId,
      }
    ]);
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
    return response.map((data) {
      final playerData = data['players'];
      final player = playerData != null ? Player((b) => b
        ..id = playerData['id']
        ..name = playerData['name']) : null;
      return Score((b) => b
        ..id = data['id']
        ..playerId = data['player_id']
        ..time = data['time']
        ..categoryId = data['category_id']
        ..player = player?.toBuilder());
    }).toList();
  }
}
