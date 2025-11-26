import 'package:flutter/material.dart';
import '../../../core/local_storage.dart';
import '../../data/movie_model.dart';
import 'movie_details_page.dart';

class WatchlistPage extends StatefulWidget {
  const WatchlistPage({Key? key}) : super(key: key);

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  final LocalStorage _storage = LocalStorage();
  late Future<List<MovieModel>> _movies;

  @override
  void initState() {
    super.initState();
    _movies = _loadMovies();
  }

  Future<List<MovieModel>> _loadMovies() async {
    final list = await _storage.getList(LocalStorage.watchlistKey);
    return list.map((json) => MovieModel.fromJson(json)).toList();
  }

  Future<void> _remove(MovieModel movie) async {
    await _storage.removeFromList(LocalStorage.watchlistKey, movie.id);
    setState(() {
      _movies = _loadMovies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: const Text("Watchlist"),
      ),
      body: FutureBuilder(
        future: _movies,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final movies = snapshot.data as List<MovieModel>;
          if (movies.isEmpty) {
            return const Center(
              child: Text(
                "No movies in watchlist",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];

              return ListTile(
                leading: Image.network(
                  "https://image.tmdb.org/t/p/w200${movie.posterPath}",
                  width: 50,
                ),
                title: Text(
                  movie.title,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  movie.releaseDate,
                  style: const TextStyle(color: Colors.white70),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MovieDetailsPage(movieId: movie.id),
                    ),
                  ).then((_) => setState(() => _movies = _loadMovies()));
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  onPressed: () => _remove(movie),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
