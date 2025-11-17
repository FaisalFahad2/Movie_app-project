import '../../core/api_client.dart';
import '../../core/constants.dart';
import 'movie_model.dart';

class MovieApi {
  final ApiClient api;

  MovieApi(this.api);

  // ───────────────────────────────────────────────
  // getRecentMovies → أفضل نسخة
  // ───────────────────────────────────────────────
  Future<List<MovieModel>> getRecentMovies() async {
    // 1) Fetch base list (from /now_playing)
    final response = await api.get(AppConstants.recentMovies);
    final List<dynamic> results = response["results"];

    List<MovieModel> movies = [];

    // 2) Loop through each movie
    for (final json in results) {
      final movieId = json["id"];

      // Fetch movie details (runtime + genres)
      Map<String, dynamic> details = {};
      try {
        details = await api.get("/movie/$movieId");
      } catch (_) {
        // ignore if details not available
      }

      // Fetch movie actors (credits)
      Map<String, dynamic> credits = {};
      try {
        credits = await api.get("/movie/$movieId/credits");
      } catch (_) {
        // ignore if credits unavailable
      }

      // ───────────────────────────────
      // Extract genres (names)
      // ───────────────────────────────
      if (details["genres"] != null) {
        json["genres"] = (details["genres"] as List)
            .map((g) => g["name"].toString())
            .toList();
      }

      // runtime
      json["runtime"] = details["runtime"];

      // ───────────────────────────────
      // Extract actors
      // ───────────────────────────────
      if (credits["cast"] != null) {
        final cast = credits["cast"] as List;
        json["actors"] = cast
            .map((actor) => actor["name"].toString())
            .toList();
      }

      // 3) Convert merged JSON → MovieModel
      movies.add(MovieModel.fromJson(json));
    }

    return movies;
  }
}
