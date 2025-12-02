import '../../features/domain/movie_entity.dart';

class MovieModel extends MovieEntity {
  double? userRating;
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
    super.actors,
    this.userRating,
  });

  // ───────────────────────────────────────────────────────────
  // fromJson → تحويل JSON من TMDB إلى MovieModel
  // ───────────────────────────────────────────────────────────
  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json["id"] is int ? json["id"] : int.parse(json["id"].toString()),
      title: json["title"]?.toString() ?? "",
      overview: json["overview"]?.toString() ?? "",
      posterPath: json["poster_path"]?.toString() ?? "",
      backdropPath: json["backdrop_path"]?.toString() ?? "",
      voteAverage: json["vote_average"] is double
          ? json["vote_average"]
          : (json["vote_average"] ?? 0).toDouble(),
      voteCount: json["vote_count"] is int
          ? json["vote_count"]
          : int.parse((json["vote_count"] ?? 0).toString()),
      popularity: json["popularity"] is double
          ? json["popularity"]
          : (json["popularity"] ?? 0).toDouble(),
      releaseDate: json["release_date"]?.toString() ?? "",
      originalLanguage: json["original_language"]?.toString() ?? "",
      genreIds:
          (json["genre_ids"] as List?)
              ?.map((e) => e is int ? e : int.parse(e.toString()))
              .toList() ??
          [],

      // optional fields (from /movie/{id} endpoint)
      runtime: json["runtime"],
      userRating: json["user_rating"] != null
          ? (json["user_rating"] as num).toDouble()
          : null,

      // convert genres objects (if available)
      genres: json["genres"] != null
          ? (json["genres"] as List).map((g) {
              if (g is Map<String, dynamic>) {
                return g["name"]?.toString() ?? "";
              } else {
                return g.toString();
              }
            }).toList()
          : null,

      // local flags → default false
      isFavorite: json["isFavorite"] ?? false,
      isInWatchlist: json["isInWatchlist"] ?? false,

      actors: json["actors"] != null ? List<String>.from(json["actors"]) : null,
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
      "backdrop_path": backdropPath,
      "vote_average": originalVoteAverage,
      "vote_count": originalVoteCount,
      "popularity": popularity,
      "release_date": releaseDate,
      "original_language": originalLanguage,
      "genre_ids": genreIds,
      if (genres != null) "genres": genres,
      if (runtime != null) "runtime": runtime,
      if (actors != null) "actors": actors,
      if (userRating != null) "user_rating": userRating, // <-- add this
    };
  }
}
