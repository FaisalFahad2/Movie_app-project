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
    try {
      final prefs = await SharedPreferences.getInstance();

      // Ensure all numeric fields are correct types
      final sanitizedMovie = {
        "id": movie["id"] is int ? movie["id"] : int.parse(movie["id"].toString()),
        "title": movie["title"]?.toString() ?? "",
        "overview": movie["overview"]?.toString() ?? "",
        "poster_path": movie["poster_path"]?.toString() ?? "",
        "backdrop_path": movie["backdrop_path"]?.toString() ?? "",
        "vote_average": movie["vote_average"] is double
            ? movie["vote_average"]
            : double.parse(movie["vote_average"].toString()),
        "vote_count": movie["vote_count"] is int
            ? movie["vote_count"]
            : int.parse(movie["vote_count"].toString()),
        "popularity": movie["popularity"] is double
            ? movie["popularity"]
            : double.parse(movie["popularity"].toString()),
        "release_date": movie["release_date"]?.toString() ?? "",
        "original_language": movie["original_language"]?.toString() ?? "",
        "genre_ids": (movie["genre_ids"] as List?)
                ?.map((e) => e is int ? e : int.parse(e.toString()))
                .toList() ??
            [],
      };

      // Get current list
      List<String> movies = prefs.getStringList(key) ?? [];

      // Check if movie already exists (prevent duplicates)
      final movieId = sanitizedMovie["id"];
      bool alreadyExists = movies.any((item) {
        final decoded = jsonDecode(item);
        return decoded["id"] == movieId;
      });

      // Only add if it doesn't exist
      if (!alreadyExists) {
        movies.add(jsonEncode(sanitizedMovie));
        await prefs.setStringList(key, movies);
      }
    } catch (e) {
      print('Error saving movie to $key: $e');
      print('Movie data: $movie');
      rethrow;
    }
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

  // ───────────────────────────────────────────────
  // MIGRATE CORRUPTED DATA
  // Clears watchlist and favorites to force re-fetch with clean data
  // User ratings are preserved - only movie data is cleared
  // ───────────────────────────────────────────────
  Future<void> clearCorruptedMovieData() async {
    final prefs = await SharedPreferences.getInstance();

    // Clear watchlist and favorites (will need to be re-added by user)
    await prefs.remove(watchlistKey);
    await prefs.remove(favoritesKey);

    // Keep user ratings - they are still valid
    // Only the movie data was corrupted, not the ratings themselves
  }
}
