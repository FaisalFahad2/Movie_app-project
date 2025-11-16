import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  // Keys
  static const String watchlistKey = "watchlist_movies";
  static const String favoritesKey = "favorite_movies";

  // ───────────────────────────────────────────────
  // SAVE MOVIE
  // movie = Map converted to JSON string
  // ───────────────────────────────────────────────
  Future<void> saveToList(String key, Map<String, dynamic> movie) async {
    final prefs = await SharedPreferences.getInstance();

    // Get current list
    List<String> movies = prefs.getStringList(key) ?? [];

    // Add new movie as JSON string
    movies.add(jsonEncode(movie));

    await prefs.setStringList(key, movies);
  }

  // ───────────────────────────────────────────────
  // REMOVE MOVIE
  // ───────────────────────────────────────────────
  Future<void> removeFromList(String key, int movieId) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> movies = prefs.getStringList(key) ?? [];

    movies.removeWhere((item) {
      final decoded = jsonDecode(item);
      return decoded["id"] == movieId;
    });

    await prefs.setStringList(key, movies);
  }

  // ───────────────────────────────────────────────
  // GET MOVIES LIST (decoded)
  // ───────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getList(String key) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> movies = prefs.getStringList(key) ?? [];

    // decode JSON → List<Map>
    return movies.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  // ───────────────────────────────────────────────
  // CHECK IF MOVIE EXISTS
  // ───────────────────────────────────────────────
  Future<bool> exists(String key, int movieId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> movies = prefs.getStringList(key) ?? [];

    return movies.any((item) {
      final decoded = jsonDecode(item);
      return decoded["id"] == movieId;
    });
  }
}
