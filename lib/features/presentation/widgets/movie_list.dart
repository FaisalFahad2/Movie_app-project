import 'package:flutter/material.dart';
import '../../data/movie_model.dart';
import '../pages/movie_details_page.dart';
import 'movie_card.dart';

class MovieList extends StatelessWidget {
  final List<MovieModel> movies;
  final int refreshKey;
  final VoidCallback? onMovieDetailsClosed;

  const MovieList({
    Key? key,
    required this.movies,
    required this.refreshKey,
    this.onMovieDetailsClosed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return const Center(
        child: Text(
          "No movies found",
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return MovieCard(
          key: ValueKey('${movie.id}_$refreshKey'),
          movie: movie,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MovieDetailsPage(movie: movie),
              ),
            );
            // Call callback to refresh parent
            onMovieDetailsClosed?.call();
          },
        );
      },
    );
  }
}
