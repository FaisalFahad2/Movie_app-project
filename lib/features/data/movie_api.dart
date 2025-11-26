import '../../core/api_client.dart';
import '../../core/constants.dart';
import 'movie_model.dart';

class MovieApi {
  final ApiClient api;

  MovieApi(this.api);

  // يجلب الآن فقط القائمة الأساسية من now_playing
  Future<List<MovieModel>> getRecentMovies() async {
    final response = await api.get(AppConstants.recentMovies);
    final List<dynamic> results = response["results"];

    return results.map((json) => MovieModel.fromJson(json)).toList();
  }

  // يجلب الممثلين لفيلم واحد
  Future<List<String>> getMovieActors(int movieId) async {
    final response = await api.get("/movie/$movieId/credits");

    if (response["cast"] == null) return [];

    final cast = response["cast"] as List;
    return cast.map((actor) => actor["name"].toString()).toList();
  }

  // يجلب تفاصيل فيلم واحد
  Future<MovieModel> getMovieDetails(int movieId) async {
    final response = await api.get("${AppConstants.movieDetails}/$movieId");
    return MovieModel.fromJson(response);
  }
}
