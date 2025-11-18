import '../../data/movie_model.dart';

class MovieSearch {
  static List<MovieModel> search(List<MovieModel> movies, String query) {
    final lower = query.toLowerCase();

    return movies.where((movie) {
      final title = movie.title.toLowerCase();
      final overview = movie.overview.toLowerCase();
      final language = movie.originalLanguage.toLowerCase();
      final genres = (movie.genres ?? []).join(" ").toLowerCase();
      final actors = (movie.actors ?? []).join(" ").toLowerCase();

      return title.contains(lower) ||
          overview.contains(lower) ||
          language.contains(lower) ||
          genres.contains(lower) ||
          actors.contains(lower);
    }).toList();
  }

  static List<MovieModel> filterByGenre(List<MovieModel> movies, int? genreId) {
    if (genreId == null) return movies;
    return movies.where((m) => m.genreIds.contains(genreId)).toList();
  }

  static List<MovieModel> filterByRating(List<MovieModel> movies, double minRating) {
    return movies.where((m) => m.voteAverage >= minRating).toList();
  }
}
