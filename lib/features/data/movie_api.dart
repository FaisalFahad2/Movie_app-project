import '../../core/api_client.dart';
import '../../core/constants.dart';
import 'movie_model.dart';

class MovieApi {
  final ApiClient api;

  MovieApi(this.api);

  // ───────────────────────────────────────────────
  // getRecentMovies
  // Fetches "now playing" movies from TMDb
  // returns: List<MovieModel>
  // ───────────────────────────────────────────────
  Future<List<MovieModel>> getRecentMovies() async {
    // 1) Call API endpoint
    final response = await api.get(AppConstants.recentMovies);

    // 2) Extract the results (list of movies)
    final List<dynamic> results = response["results"];

    // 3) Convert JSON → MovieModel
    return results.map((json) => MovieModel.fromJson(json)).toList();
  }
}
