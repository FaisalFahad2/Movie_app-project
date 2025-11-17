import 'package:flutter/material.dart';
import '../../../core/api_client.dart';
import '../../data/movie_api.dart';
import '../../domain/movie_entity.dart';
import '../widgets/movie_list.dart';
import '../widgets/search_filter_bar.dart';

class RecentMoviesPage extends StatefulWidget {
  const RecentMoviesPage({Key? key}) : super(key: key);

  @override
  _RecentMoviesPageState createState() => _RecentMoviesPageState();
}

class _RecentMoviesPageState extends State<RecentMoviesPage> {
  late Future<List<MovieEntity>> _futureMovies;

  // Original movies (20 movies)
  List<MovieEntity> allMovies = [];

  // Filtered movies (after search/filters)
  List<MovieEntity> filteredMovies = [];

  @override
  void initState() {
    super.initState();
    final movieApi = MovieApi(ApiClient());

    _futureMovies = movieApi.getRecentMovies().then((movies) {
      allMovies = movies;
      filteredMovies = movies;
      return movies;
    });
  }

  // ─────────────────────────────────────────────
  // 🔎 Search Function
  // ─────────────────────────────────────────────
  void _searchMovies(String query) {
    setState(() {
      final lower = query.toLowerCase();

      filteredMovies = allMovies.where((movie) {
        final title = movie.title.toLowerCase();
        final overview = movie.overview.toLowerCase();
        final language = movie.originalLanguage.toLowerCase();
        final genres = movie.genres?.join(" ").toLowerCase() ?? "";
        final actorsString = movie.actors?.join(" ").toLowerCase() ?? "";

        return title.contains(lower) ||
            overview.contains(lower) ||
            language.contains(lower) ||
            genres.contains(lower) ||
            actorsString.contains(lower);
      }).toList();
    });
  }

  // ─────────────────────────────────────────────
  // 🎭 Filter by Genre
  // ─────────────────────────────────────────────
  void _filterByGenre(int? genreId) {
    setState(() {
      if (genreId == null) {
        filteredMovies = allMovies;
        return;
      }

      filteredMovies =
          allMovies.where((movie) => movie.genreIds.contains(genreId)).toList();
    });
  }

  // ─────────────────────────────────────────────
  // ⭐ Filter by Rating
  // ─────────────────────────────────────────────
  void _filterByRating(double minRating) {
    setState(() {
      filteredMovies =
          allMovies.where((movie) => movie.voteAverage >= minRating).toList();
    });
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

          // 🟢 DATA IS READY
          return Column(
            children: [
              // ───────── Search + Filters Widget ─────────
              SearchAndFilterBar(
                onSearchChanged: _searchMovies,
                onGenreSelected: _filterByGenre,
                onRatingChanged: _filterByRating,
              ),

              // ───────── Movies List ─────────
              Expanded(
                child: MovieList(movies: filteredMovies),
              ),
            ],
          );
        },
      ),
    );
  }
}
