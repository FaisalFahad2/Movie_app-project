import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  // Keys
  static const String watchlistKey = "watchlist_movies";
  static const String favoritesKey = "favorite_movies";
  static const String userRatingsKey = "user_ratings";

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

  // ───────────────────────────────────────────────
  // SAVE USER RATING
  // Stores movieId -> rating (1-10)
  // ───────────────────────────────────────────────
  Future<void> saveUserRating(int movieId, double rating) async {
    final prefs = await SharedPreferences.getInstance();
    String key = '${userRatingsKey}_$movieId';
    await prefs.setDouble(key, rating);
  }

  // ───────────────────────────────────────────────
  // GET USER RATING
  // Returns null if user hasn't rated this movie
  // ───────────────────────────────────────────────
  Future<double?> getUserRating(int movieId) async {
    final prefs = await SharedPreferences.getInstance();
    String key = '${userRatingsKey}_$movieId';
    return prefs.getDouble(key);
  }

  // ───────────────────────────────────────────────
  // CHECK IF USER HAS RATED
  // ───────────────────────────────────────────────
  Future<bool> hasUserRated(int movieId) async {
    final rating = await getUserRating(movieId);
    return rating != null;
  }

  // ───────────────────────────────────────────────
  // CALCULATE ADJUSTED RATING
  // Recalculates average with user's rating included
  // ───────────────────────────────────────────────
  Future<Map<String, dynamic>> getAdjustedRating(
    int movieId,
    double originalAverage,
    int originalCount,
  ) async {
    final userRating = await getUserRating(movieId);

    if (userRating == null) {
      return {
        'average': originalAverage,
        'count': originalCount,
      };
    }

    // Calculate new average with user's rating
    double totalRating = originalAverage * originalCount;
    double newAverage = (totalRating + userRating) / (originalCount + 1);
    // Round to 1 decimal place
    newAverage = double.parse(newAverage.toStringAsFixed(1));

    return {
      'average': newAverage,
      'count': originalCount + 1,
    };
  }
}
