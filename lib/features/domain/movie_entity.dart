class MovieEntity {
  final int id;
  final String title;
  final String overview;

  final String posterPath;
  final String backdropPath;

  double voteAverage;
  int voteCount;
  final double popularity;

  final String releaseDate;
  final String originalLanguage;

  final List<int> genreIds;        // From API
  final List<String>? genres;      // Optional: full names

  final int? runtime;              // For details screen

  final bool isFavorite;           // Local flags
  final bool isInWatchlist;

  List<String>? actors;

  MovieEntity({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.voteCount,
    required this.popularity,
    required this.releaseDate,
    required this.originalLanguage,
    required this.genreIds,
    this.genres,
    this.runtime,
    this.isFavorite = false,
    this.isInWatchlist = false,

    this.actors
  });

  // Update rating with user's rating
  void updateWithUserRating(double userRating) {
    double totalRating = voteAverage * voteCount;
    double newAverage = (totalRating + userRating) / (voteCount + 1);
    voteAverage = double.parse(newAverage.toStringAsFixed(1));
    voteCount = voteCount + 1;
  }
}
