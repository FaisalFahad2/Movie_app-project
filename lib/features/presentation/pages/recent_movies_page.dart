import 'package:flutter/material.dart';
import '../../../core/api_client.dart';
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

  // ───────── Refresh Key for MovieCard rebuild ─────────
  int _refreshKey = 0;

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

      // NO LONGER apply user ratings here - let UI calculate on display

      // Enrich with details and actors in background
      _enrichMoviesInBackground(movieApi, movies);

      return movies;
    });
  }

  // REMOVED: _applyUserRatings() method
  // This method caused double-counting by mutating movies
  // Rating calculation is now handled in MovieCard UI

  // ─────────────────────────────────────────────
  // Refresh UI when returning from details
  // Increment refresh key to force MovieCard rebuild
  // ─────────────────────────────────────────────
  Future<void> _refreshRatings() async {
    if (mounted) {
      setState(() {
        _refreshKey++;
      });
    }
  }

  // ─────────────────────────────────────────────
  // Enrich movies with full details and actors in background
  // ─────────────────────────────────────────────
  Future<void> _enrichMoviesInBackground(
    MovieApi api,
    List<MovieModel> movies,
  ) async {
    // Phase 1: Load genres & runtime for all movies
    for (final movie in movies) {
      await api.enrichMovieWithDetails(movie);
      if (mounted) setState(() {}); // Progressive UI update
    }

    // Phase 2: Load actors (lower priority)
    for (final movie in movies) {
      try {
        final actors = await api.getMovieActors(movie.id);
        movie.actors = actors;
        if (mounted) setState(() {});
      } catch (e) {
        print('Failed to load actors for ${movie.id}: $e');
      }
    }
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
                  refreshKey: _refreshKey,
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
