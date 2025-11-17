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
    // 1) Fetch list of movies
    final response = await api.get(AppConstants.recentMovies);
    final List<dynamic> results = response["results"];

    // 2) Convert to MovieModel
    List<MovieModel> movies =
    results.map((json) => MovieModel.fromJson(json)).toList();

    // 3) Fetch actors for each movie
    for (int i = 0; i < movies.length; i++) {
      final movieId = movies[i].id;

      try {
        final actors = await getMovieActors(movieId);

        movies[i] = MovieModel(
          id: movies[i].id,
          title: movies[i].title,
          overview: movies[i].overview,
          posterPath: movies[i].posterPath,
          backdropPath: movies[i].backdropPath,
          voteAverage: movies[i].voteAverage,
          voteCount: movies[i].voteCount,
          popularity: movies[i].popularity,
          releaseDate: movies[i].releaseDate,
          originalLanguage: movies[i].originalLanguage,
          genreIds: movies[i].genreIds,
          genres: movies[i].genres,
          runtime: movies[i].runtime,
          actors: actors,                // ← هنا نضيف الممثلين
          isFavorite: movies[i].isFavorite,
          isInWatchlist: movies[i].isInWatchlist,
        );
      } catch (_) {
        // ignore errors if credits not available
      }
    }

    return movies;
  }


  Future<List<String>> getMovieActors(int movieId) async {
    final response = await api.get("/movie/$movieId/credits");

    final cast = response["cast"] as List;
    final actors = cast.map((actor) => actor["name"].toString()).toList();

    return actors;
  }


}
