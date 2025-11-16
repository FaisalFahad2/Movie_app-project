import 'package:flutter/material.dart';
import '../../domain/movie_entity.dart';
import 'movie_card.dart';

class MovieList extends StatelessWidget {
  final List<MovieEntity> movies;

  const MovieList({
    Key? key,
    required this.movies,
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
          onTap: () {
            // يمكنك لاحقًا فتح صفحة التفاصيل هنا
            print("Tapped: ${movie.title}");
          },
        );
      },
    );
  }
}
