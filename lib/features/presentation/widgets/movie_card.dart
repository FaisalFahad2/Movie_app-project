import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/local_storage.dart';
import '../../data/movie_model.dart';

class MovieCard extends StatefulWidget {
  final MovieModel movie;
  final VoidCallback? onTap;

  const MovieCard({
    Key? key,
    required this.movie,
    this.onTap,
  }) : super(key: key);

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  double? _displayAverage;

  @override
  void initState() {
    super.initState();
    _loadRating();
  }

  Future<void> _loadRating() async {
    final storage = LocalStorage();
    final adjusted = await storage.getAdjustedRating(
      widget.movie.id,
      widget.movie.originalVoteAverage,
      widget.movie.originalVoteCount,
    );

    if (mounted) {
      setState(() {
        _displayAverage = adjusted['average'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayAverage = _displayAverage ?? widget.movie.originalVoteAverage;
    return GestureDetector(
      onTap: widget.onTap,
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
                "${AppConstants.imageBaseUrl}${widget.movie.posterPath}",
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
                    widget.movie.title,
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
                    widget.movie.releaseDate.isNotEmpty
                        ? widget.movie.releaseDate.substring(0, 4)
                        : "Unknown",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Star + Rating (calculated from original values)
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        displayAverage.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
