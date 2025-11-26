import 'package:flutter/material.dart';
import '../../../core/api_client.dart';
import '../../../core/local_storage.dart';
import '../../data/movie_api.dart';
import '../../data/movie_model.dart';
import '../utils/movie_search.dart';
import '../widgets/movie_list.dart';
import '../widgets/search_filter_bar.dart';

class RecentMoviesPage extends StatefulWidget {
  const RecentMoviesPage({Key? key}) : super(key: key);

  @override
  _RecentMoviesPageState createState() => _RecentMoviesPageState();
}

class _RecentMoviesPageState extends State<RecentMoviesPage> {
  late Future<List<MovieModel>> _futureMovies;

  List<MovieModel> allMovies = [];
  List<MovieModel> filteredMovies = [];

  // ───────── Save Last Filters ─────────
  String _currentSearch = "";
  int? _currentGenre;
  double _currentRating = 0;

  @override
  void initState() {
    super.initState();

    final movieApi = MovieApi(ApiClient());

    _futureMovies = movieApi.getRecentMovies().then((movies) async {
      allMovies = movies;
      filteredMovies = movies;

      // Apply user ratings to movies
      await _applyUserRatings(movies);

      _loadActorsInBackground(movieApi, movies);

      return movies;
    });
  }

  // ─────────────────────────────────────────────
  // Apply user ratings to movies
  // ─────────────────────────────────────────────
  Future<void> _applyUserRatings(List<MovieModel> movies) async {
    final storage = LocalStorage();
    for (final movie in movies) {
      final userRating = await storage.getUserRating(movie.id);
      if (userRating != null) {
        movie.updateWithUserRating(userRating);
      }
    }
  }

  // ─────────────────────────────────────────────
  // Refresh ratings when returning from details
  // We need to reload from API to get fresh data
  // ─────────────────────────────────────────────
  Future<void> _refreshRatings() async {
    final movieApi = MovieApi(ApiClient());

    try {
      final freshMovies = await movieApi.getRecentMovies();
      allMovies = freshMovies;

      // Apply user ratings to fresh data
      await _applyUserRatings(allMovies);

      // Re-apply current filters
      _applyFilters();
    } catch (e) {
      // If refresh fails, just continue with current data
      if (mounted) setState(() {});
    }
  }

  // ─────────────────────────────────────────────
  // Load actors in background (no UI freeze)
  // ─────────────────────────────────────────────
  Future<void> _loadActorsInBackground(MovieApi api, List<MovieModel> movies) async {
    for (final movie in movies) {
      final actors = await api.getMovieActors(movie.id);
      movie.actors = actors;
    }
    if (mounted) setState(() {});
  }

  // ─────────────────────────────────────────────
  // Unified filter logic (search + genre + rating)
  // ─────────────────────────────────────────────
  void _applyFilters() {
    List<MovieModel> result = allMovies;

    // 1) genre filter
    if (_currentGenre != null) {
      result = MovieSearch.filterByGenre(result, _currentGenre);
    }

    // 2) rating filter
    result = MovieSearch.filterByRating(result, _currentRating);

    // 3) search
    result = MovieSearch.search(result, _currentSearch);

    setState(() {
      filteredMovies = result;
    });
  }

  // ─────────────────────────────────────────────
  // Search
  // ─────────────────────────────────────────────
  void _searchMovies(String query) {
    _currentSearch = query;
    _applyFilters();
  }

  // ─────────────────────────────────────────────
  // Filter by Genre
  // ─────────────────────────────────────────────
  void _filterByGenre(int? genreId) {
    _currentGenre = genreId;
    _applyFilters();
  }

  // ─────────────────────────────────────────────
  // Filter by Rating
  // ─────────────────────────────────────────────
  void _filterByRating(double rating) {
    _currentRating = rating;
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: const Text("Recent Movies"),
        backgroundColor: const Color(0xFF0D1117),
        elevation: 0,
      ),

      body: FutureBuilder<List<MovieModel>>(
        future: _futureMovies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          return Column(
            children: [
              SearchAndFilterBar(
                onSearchChanged: _searchMovies,
                onGenreSelected: _filterByGenre,
                onRatingChanged: _filterByRating,
              ),

              Expanded(
                child: MovieList(
                  movies: filteredMovies,
                  onMovieDetailsClosed: _refreshRatings,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
