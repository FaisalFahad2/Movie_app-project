import '../../features/domain/movie_entity.dart';

class MovieModel extends MovieEntity {
  MovieModel({
    required super.id,
    required super.title,
    required super.overview,
    required super.posterPath,
    required super.backdropPath,
    required super.voteAverage,
    required super.voteCount,
    required super.popularity,
    required super.releaseDate,
    required super.originalLanguage,
    required super.genreIds,
    super.genres,
    super.runtime,
    super.isFavorite,
    super.isInWatchlist,
  });

  // ───────────────────────────────────────────────────────────
  // fromJson → تحويل JSON من TMDB إلى MovieModel
  // ───────────────────────────────────────────────────────────
  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json["id"] ?? 0,
      title: json["title"] ?? "",
      overview: json["overview"] ?? "",
      posterPath: json["poster_path"] ?? "",
      backdropPath: json["backdrop_path"] ?? "",
      voteAverage: (json["vote_average"] ?? 0).toDouble(),
      voteCount: (json["vote_count"] ?? 0),
      popularity: (json["popularity"] ?? 0).toDouble(),
      releaseDate: json["release_date"] ?? "",
      originalLanguage: json["original_language"] ?? "",
      genreIds: List<int>.from(json["genre_ids"] ?? []),

      // optional fields (from /movie/{id} endpoint)
      runtime: json["runtime"],

      // convert genres objects (if available)
      genres: json["genres"] != null
          ? (json["genres"] as List)
          .map((g) => g["name"].toString())
          .toList()
          : null,

      // local flags → default false
      isFavorite: json["isFavorite"] ?? false,
      isInWatchlist: json["isInWatchlist"] ?? false,
    );
  }

  // ───────────────────────────────────────────────────────────
  // toJson → نحتاجها للتخزين المحلي SharedPreferences
  // ───────────────────────────────────────────────────────────
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "overview": overview,
      "poster_path": posterPath,
      "backback_path": backdropPath,
      "vote_average": voteAverage,
      "vote_count": voteCount,
      "popularity": popularity,
      "release_date": releaseDate,
      "original_language": originalLanguage,
      "genre_ids": genreIds,
      "genres": genres,
      "runtime": runtime,
      "isFavorite": isFavorite,
      "isInWatchlist": isInWatchlist,
    };
  }
}
