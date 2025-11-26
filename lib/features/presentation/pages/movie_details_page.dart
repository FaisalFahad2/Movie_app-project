import 'package:flutter/material.dart';
import '../../../core/api_client.dart';
import '../../../core/constants.dart';
import '../../../core/local_storage.dart';
import '../../data/movie_api.dart';
import '../../data/movie_model.dart';
import '../widgets/user_rating_widget.dart';

class MovieDetailsPage extends StatefulWidget {
  final int movieId;

  const MovieDetailsPage({super.key, required this.movieId});

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

  bool isInWatchlist = false;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    final api = MovieApi(ApiClient());

    _movieFuture = api.getMovieDetails(widget.movieId).then((movie) async {
      await _loadUserRating(movie);
      return movie;
    });

    _actorsFuture = api.getMovieActors(widget.movieId);

    checkLists(); // ← تحميل حالة watchlist/favorite عند فتح الصفحة
  }

  Future<void> checkLists() async {
    isInWatchlist = await _storage.exists(
      LocalStorage.watchlistKey,
      widget.movieId,
    );

    isFavorite = await _storage.exists(
      LocalStorage.favoritesKey,
      widget.movieId,
    );

    if (mounted) setState(() {});
  }

  Future<void> toggleWatchlist(MovieModel movie) async {
    try {
      if (isInWatchlist) {
        await _storage.removeFromList(LocalStorage.watchlistKey, movie.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Removed from watchlist'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      } else {
        await _storage.saveToList(LocalStorage.watchlistKey, movie.toJson());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Added to watchlist'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
      await checkLists();
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

  Future<void> toggleFavorite(MovieModel movie) async {
    try {
      if (isFavorite) {
        await _storage.removeFromList(LocalStorage.favoritesKey, movie.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Removed from favorites'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      } else {
        await _storage.saveToList(LocalStorage.favoritesKey, movie.toJson());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Added to favorites'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
      await checkLists();
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
                      Text(
                        movie.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              isInWatchlist
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () => toggleWatchlist(movie),
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
                            onPressed: () => toggleFavorite(movie),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

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

                      const SizedBox(height: 20),

                      UserRatingWidget(
                        currentUserRating: _userRating,
                        onRate: (rating) => _handleRating(rating, movie),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        movie.overview,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 40),
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
