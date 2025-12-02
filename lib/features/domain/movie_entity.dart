class MovieEntity {
  final int id;
  final String title;
  final String overview;

  final String posterPath;
  final String backdropPath;

  // Original TMDB data (immutable) - NEVER mutate these
  final double originalVoteAverage;
  final int originalVoteCount;

  // Display values (can be used for UI, but NOT persisted)
  double voteAverage;
  int voteCount;
  final double popularity;

  final String releaseDate;
  final String originalLanguage;

  final List<int> genreIds;        // From API
  List<String>? genres;            // Optional: full names (mutable for enrichment)

  int? runtime;                    // For details screen (mutable for enrichment)

  final bool isFavorite;           // Local flags
  final bool isInWatchlist;

  List<String>? actors;

  MovieEntity({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required double voteAverage,
    required int voteCount,
    required this.popularity,
    required this.releaseDate,
    required this.originalLanguage,
    required this.genreIds,
    this.genres,
    this.runtime,
    this.isFavorite = false,
    this.isInWatchlist = false,
    this.actors,
  }) : originalVoteAverage = voteAverage,
       originalVoteCount = voteCount,
       this.voteAverage = voteAverage,
       this.voteCount = voteCount;

  // REMOVED: updateWithUserRating() method
  // This method caused double-counting by mutating the movie object
  // Rating calculation is now handled by LocalStorage.getAdjustedRating()
}
