import 'package:flutter/material.dart';
import '../../../core/api_client.dart';
import '../../../core/constants.dart';
import '../../../core/local_storage.dart';
import '../../data/movie_api.dart';
import '../../data/movie_model.dart';
import '../widgets/user_rating_widget.dart';

class MovieDetailsPage extends StatefulWidget {
  final int movieId;

  const MovieDetailsPage({
    super.key,
    required this.movieId,
  });

  @override
  State<MovieDetailsPage> createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  late Future<MovieModel> _movieFuture;
  late Future<List<String>> _actorsFuture;
  final LocalStorage _storage = LocalStorage();

  double? _userRating;
  double _displayedAverage = 0.0;
  int _displayedCount = 0;

  @override
  void initState() {
    super.initState();
    final api = MovieApi(ApiClient());
    _movieFuture = api.getMovieDetails(widget.movieId).then((movie) async {
      await _loadUserRating(movie);
      return movie;
    });
    _actorsFuture = api.getMovieActors(widget.movieId);
  }

  Future<void> _loadUserRating(MovieModel movie) async {
    final rating = await _storage.getUserRating(widget.movieId);
    if (rating != null) {
      final adjusted = await _storage.getAdjustedRating(
        widget.movieId,
        movie.voteAverage,
        movie.voteCount,
      );
      if (mounted) {
        setState(() {
          _userRating = rating;
          _displayedAverage = adjusted['average'];
          _displayedCount = adjusted['count'];
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _userRating = null;
        });
      }
    }
  }

  Future<void> _handleRating(double rating, MovieModel movie) async {
    await _storage.saveUserRating(widget.movieId, rating);

    final adjusted = await _storage.getAdjustedRating(
      widget.movieId,
      movie.voteAverage,
      movie.voteCount,
    );

    if (mounted) {
      setState(() {
        _userRating = rating;
        _displayedAverage = adjusted['average'];
        _displayedCount = adjusted['count'];
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rating saved successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: const Text('Movie Details'),
      ),
      body: FutureBuilder<MovieModel>(
        future: _movieFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'No movie data found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final movie = snapshot.data!;

          // Use adjusted rating if user has rated, otherwise use original
          final displayAverage = _displayedAverage > 0
              ? _displayedAverage
              : movie.voteAverage;
          final displayCount = _displayedCount > 0
              ? _displayedCount
              : movie.voteCount;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Backdrop Image
                Image.network(
                  "${AppConstants.imageBaseUrl}${movie.backdropPath}",
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        movie.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Release Date & Rating
                      Row(
                        children: [
                          Text(
                            movie.releaseDate.isNotEmpty
                                ? movie.releaseDate.substring(0, 4)
                                : "Unknown",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            displayAverage.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "($displayCount votes)",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Runtime & Language
                      Row(
                        children: [
                          if (movie.runtime != null) ...[
                            const Icon(Icons.access_time,
                                color: Colors.grey, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              "${movie.runtime} min",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                          const Icon(Icons.language,
                              color: Colors.grey, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            movie.originalLanguage.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Genres
                      if (movie.genres != null && movie.genres!.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          children: movie.genres!
                              .map((genre) => Chip(
                                    label: Text(genre),
                                    backgroundColor: const Color(0xFF1F6FEB),
                                    labelStyle:
                                        const TextStyle(color: Colors.white),
                                  ))
                              .toList(),
                        ),

                      const SizedBox(height: 24),

                      // Overview Section
                      const Text(
                        "Overview",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        movie.overview,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Cast Section
                      const Text(
                        "Cast",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      FutureBuilder<List<String>>(
                        future: _actorsFuture,
                        builder: (context, actorSnapshot) {
                          if (actorSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }

                          if (actorSnapshot.hasError ||
                              !actorSnapshot.hasData ||
                              actorSnapshot.data!.isEmpty) {
                            return const Text(
                              "No cast information available",
                              style: TextStyle(color: Colors.grey),
                            );
                          }

                          final actors = actorSnapshot.data!;
                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: actors
                                .take(10)
                                .map((actor) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF161B22),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        actor,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          );
                        },
                      ),

                      const SizedBox(height: 40),

                      // User Rating Section
                      const Text(
                        "Rate This Movie",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      UserRatingWidget(
                        currentUserRating: _userRating,
                        onRate: (rating) => _handleRating(rating, movie),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
