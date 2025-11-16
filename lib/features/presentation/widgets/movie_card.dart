import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../domain/movie_entity.dart';

class MovieCard extends StatelessWidget {
  final MovieEntity movie;
  final VoidCallback? onTap;

  const MovieCard({
    Key? key,
    required this.movie,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // ───────── Poster ─────────
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                "${AppConstants.imageBaseUrl}${movie.posterPath}",
                width: 75,
                height: 110,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 12),

            // ───────── Text Info ─────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    movie.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Release Year
                  Text(
                    movie.releaseDate.isNotEmpty
                        ? movie.releaseDate.substring(0, 4)
                        : "Unknown",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Star + Rating
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        movie.voteAverage.toString(),
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Genres
                  if (movie.genres != null)
                    Text(
                      movie.genres!.join(", "),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),

                  // Runtime
                  if (movie.runtime != null)
                    Text(
                      "${(movie.runtime! ~/ 60)}h ${(movie.runtime! % 60)}m",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
