import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/local_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Run data migration once to fix corrupted ratings
  await _migrateData();

  runApp(const MyApp());
}

Future<void> _migrateData() async {
  final storage = LocalStorage();
  final prefs = await SharedPreferences.getInstance();

  // Check if migration already done
  final migrated = prefs.getBool('ratings_migration_v1') ?? false;

  if (!migrated) {
    await storage.clearCorruptedMovieData();
    await prefs.setBool('ratings_migration_v1', true);
    print('✅ Cleared corrupted movie data. Users will need to re-add to watchlist/favorites.');
    print('✅ User ratings are preserved and will work correctly.');
  }
}
