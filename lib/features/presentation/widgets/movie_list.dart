import 'package:flutter/material.dart';
import '../../domain/movie_entity.dart';
import '../pages/movie_details_page.dart';
import 'movie_card.dart';

class MovieList extends StatelessWidget {
  final List<MovieEntity> movies;
  final VoidCallback? onMovieDetailsClosed;

  const MovieList({
    Key? key,
    required this.movies,
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
          movie: movie,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MovieDetailsPage(movieId: movie.id),
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
