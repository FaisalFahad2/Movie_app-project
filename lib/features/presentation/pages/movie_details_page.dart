import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/local_storage.dart';
import '../../data/movie_model.dart';
import '../widgets/user_rating_widget.dart';

class MovieDetailsPage extends StatefulWidget {
  final MovieModel movie;

  const MovieDetailsPage({super.key, required this.movie});

  @override
  State<MovieDetailsPage> createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  final LocalStorage _storage = LocalStorage();

  // Local state for user interactions only
  double? _userRating;
  double _displayedAverage = 0.0;
  int _displayedCount = 0;
  bool isInWatchlist = false;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadUserRating();
    _checkLists();
  }

  Future<void> _checkLists() async {
    isInWatchlist = await _storage.exists(
      LocalStorage.watchlistKey,
      widget.movie.id,
    );

    isFavorite = await _storage.exists(
      LocalStorage.favoritesKey,
      widget.movie.id,
    );

    if (mounted) setState(() {});
  }

  Future<void> toggleWatchlist() async {
    try {
      if (isInWatchlist) {
        await _storage.removeFromList(LocalStorage.watchlistKey, widget.movie.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Removed from watchlist'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      } else {
        await _storage.saveToList(LocalStorage.watchlistKey, widget.movie.toJson());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Added to watchlist'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
      await _checkLists();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> toggleFavorite() async {
    try {
      if (isFavorite) {
        await _storage.removeFromList(LocalStorage.favoritesKey, widget.movie.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Removed from favorites'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      } else {
        await _storage.saveToList(LocalStorage.favoritesKey, widget.movie.toJson());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Added to favorites'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
      await _checkLists();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadUserRating() async {
    final rating = await _storage.getUserRating(widget.movie.id);
    if (rating != null) {
      final adjusted = await _storage.getAdjustedRating(
        widget.movie.id,
        widget.movie.originalVoteAverage,  // Use ORIGINAL
        widget.movie.originalVoteCount,    // Use ORIGINAL
      );

      if (mounted) {
        setState(() {
          _userRating = rating;
          _displayedAverage = adjusted['average'];
          _displayedCount = adjusted['count'];
        });
      }
    }
  }

  Future<void> _handleRating(double rating) async {
    await _storage.saveUserRating(widget.movie.id, rating);

    final adjusted = await _storage.getAdjustedRating(
      widget.movie.id,
      widget.movie.originalVoteAverage,  // Use ORIGINAL
      widget.movie.originalVoteCount,    // Use ORIGINAL
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
    final movie = widget.movie;

    final displayAverage = _displayedAverage > 0
        ? _displayedAverage
        : movie.originalVoteAverage;  // Use ORIGINAL

    final displayCount = _displayedCount > 0
        ? _displayedCount
        : movie.originalVoteCount;    // Use ORIGINAL

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: const Text('Movie Details'),
      ),
      body: SingleChildScrollView(
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

                  const SizedBox(height: 12),

                  // Watchlist & Favorite Buttons
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isInWatchlist
                              ? Icons.visibility
                              : Icons.visibility_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: toggleWatchlist,
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.red,
                          size: 28,
                        ),
                        onPressed: toggleFavorite,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Year, Rating, Vote Count
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
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // GENRES (NEW)
                  if (movie.genres != null && movie.genres!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Genres",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          children: movie.genres!.map((genre) {
                            return Chip(
                              label: Text(genre),
                              backgroundColor: const Color(0xFF1F6FEB),
                              labelStyle: const TextStyle(color: Colors.white),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),

                  // RUNTIME (NEW)
                  if (movie.runtime != null && movie.runtime! > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.access_time, color: Colors.grey, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "${movie.runtime! ~/ 60}h ${movie.runtime! % 60}m",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),

                  // User Rating Widget
                  UserRatingWidget(
                    currentUserRating: _userRating,
                    onRate: _handleRating,
                  ),

                  const SizedBox(height: 20),

                  // Overview
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
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // CAST (NEW)
                  if (movie.actors != null && movie.actors!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Cast",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...movie.actors!.take(5).map((actor) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.person, color: Colors.grey, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  actor,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
