class AppConstants {
  // ──────────────────────────────────────────────
  // API KEY
  // ──────────────────────────────────────────────
  static const String apiKey = "c0139e87cb189f7d83b47ff590a62abe";

  // ──────────────────────────────────────────────
  // BASE URL
  // ──────────────────────────────────────────────
  static const String baseUrl = "https://api.themoviedb.org/3";

  // Base image path for posters & backdrops
  static const String imageBaseUrl = "https://image.tmdb.org/t/p/w500";

  // ──────────────────────────────────────────────
  // ENDPOINTS
  // ──────────────────────────────────────────────
  static const String recentMovies = "/movie/now_playing";
  static const String topRatedMovies = "/movie/top_rated";
  static const String movieDetails = "/movie"; // + /{movie_id}

  // ──────────────────────────────────────────────
  // OTHER CONSTANTS
  // ──────────────────────────────────────────────
  static const String appName = "Movie App";
}
