import 'package:flutter/material.dart';
import '../../../core/api_client.dart';
import '../../../core/constants.dart';
import '../../data/movie_api.dart';
import '../../data/movie_model.dart';
import '../../domain/movie_entity.dart';
import '../widgets/movie_list.dart';

class RecentMoviesPage extends StatefulWidget {
  const RecentMoviesPage({Key? key}) : super(key: key);

  @override
  _RecentMoviesPageState createState() => _RecentMoviesPageState();
}

class _RecentMoviesPageState extends State<RecentMoviesPage> {
  late Future<List<MovieEntity>> _futureMovies;

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient();
    final movieApi = MovieApi(apiClient);
    _futureMovies = movieApi.getRecentMovies();
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

      body: FutureBuilder<List<MovieEntity>>(
        future: _futureMovies,
        builder: (context, snapshot) {
          // 🟡 Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            );
          }

          // 🔴 Error
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }

          // 🟢 Data Loaded
          final movies = snapshot.data!;
          return MovieList(movies: movies);
        },
      ),
    );
  }
}
