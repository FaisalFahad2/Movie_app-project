import 'package:flutter/material.dart';
import '../../../core/local_storage.dart';
import '../../data/movie_model.dart';
import '../utils/movie_search.dart';
import '../widgets/movie_list.dart';
import '../widgets/search_filter_bar.dart';

class WatchlistPage extends StatefulWidget {
  const WatchlistPage({super.key});

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  final LocalStorage _storage = LocalStorage();
  late Future<List<Map<String, dynamic>>> _moviesFuture;
  int _refreshKey = 0;
  String _searchQuery = "";
  int? _currentGenre;
  double _currentRating = 0;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  void _loadMovies() {
    _moviesFuture = _storage.getList(LocalStorage.watchlistKey);
  }

  void _refreshMovies() {
    if (mounted) {
      setState(() {
        _refreshKey++;
        _loadMovies();
      });
    }
  }

  List<MovieModel> _applyFilters(List<MovieModel> movies) {
    var result = movies;
    if (_currentGenre != null) {
      result = MovieSearch.filterByGenre(result, _currentGenre);
    }
    result = MovieSearch.filterByRating(result, _currentRating);
    return MovieSearch.search(result, _searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: const Text("Watchlist"),
        backgroundColor: const Color(0xFF161B22),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _moviesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final moviesData = snapshot.data ?? [];

          if (moviesData.isEmpty) {
            return const Center(
              child: Text(
                "No movies in watchlist",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final movies =
              moviesData.map((data) => MovieModel.fromJson(data)).toList();
          final filteredMovies = _applyFilters(movies);

          return Column(
            children: [
              SearchAndFilterBar(
                onSearchChanged: (v) => setState(() => _searchQuery = v),
                onGenreSelected: (g) => setState(() => _currentGenre = g),
                onRatingChanged: (r) => setState(() => _currentRating = r),
              ),
              Expanded(
                child: MovieList(
                  movies: filteredMovies,
                  refreshKey: _refreshKey,
                  onMovieDetailsClosed: _refreshMovies,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
