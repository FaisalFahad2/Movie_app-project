import 'package:flutter/material.dart';
import '../../../core/local_storage.dart';
import '../../data/movie_model.dart';
import '../widgets/movie_list.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final LocalStorage _storage = LocalStorage();
  late Future<List<Map<String, dynamic>>> _moviesFuture;
  int _refreshKey = 0;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  void _loadMovies() {
    _moviesFuture = _storage.getList(LocalStorage.favoritesKey);
  }

  void _refreshMovies() {
    if (mounted) {
      setState(() {
        _refreshKey++;
        _loadMovies();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: const Text("Favorites"),
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
                "No favorite movies yet",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final movies = moviesData
              .map((data) => MovieModel.fromJson(data))
              .toList();

          return MovieList(
            movies: movies,
            refreshKey: _refreshKey,
            onMovieDetailsClosed: _refreshMovies,
          );
        },
      ),
    );
  }
}
