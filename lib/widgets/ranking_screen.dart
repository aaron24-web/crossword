import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../database_service.dart';
import '../model.dart';
import '../supabase_service.dart';
import '../utils.dart';

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final dbService = DatabaseService(SupabaseService.client);
  return dbService.getCategories();
});

final selectedCategoryProvider = StateProvider<Category?>((ref) {
  final categories = ref.watch(categoriesProvider);
  return categories.asData?.value.first;
});

final scoresProvider = FutureProvider<List<Score>>((ref) async {
  final selectedCategory = ref.watch(selectedCategoryProvider);
  if (selectedCategory != null) {
    final dbService = DatabaseService(SupabaseService.client);
    return dbService.getScoresByCategory(selectedCategory.id);
  }
  return [];
});

class RankingScreen extends ConsumerWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final scores = ref.watch(scoresProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Ranking'),
      ),
      body: Column(
        children: [
          categories.when(
            data: (data) => DropdownButton<Category>(
              value: selectedCategory,
              items: data
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category.name),
                      ))
                  .toList(),
              onChanged: (category) {
                ref.read(selectedCategoryProvider.notifier).state = category;
              },
            ),
            loading: () => CircularProgressIndicator(),
            error: (error, stackTrace) => Text('Error: $error'),
          ),
          Expanded(
            child: scores.when(
              data: (data) => ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final score = data[index];
                  return ListTile(
                    leading: Text('${index + 1}'),
                    title: Text(score.player?.name ?? 'Jugador anónimo'),
                    trailing: Text(Duration(seconds: score.time).formatted),
                  );
                },
              ),
              loading: () => CircularProgressIndicator(),
              error: (error, stackTrace) => Text('Error: $error'),
            ),
          ),
        ],
      ),
    );
  }
}
