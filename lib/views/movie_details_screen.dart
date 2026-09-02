import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter_iti_movie_app/models/movie_record.dart";
import "package:flutter_iti_movie_app/services/watched_cloud_service.dart";
import "package:flutter_iti_movie_app/utils/theme.dart";
import "package:flutter_iti_movie_app/widgets/rating_stars.dart";
import "package:flutter_iti_movie_app/widgets/wide_button.dart";

class MovieDetailsScreen extends StatefulWidget {
  const MovieDetailsScreen({super.key, required this.movie});
  final MovieRecord movie;

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  bool _isWatched = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadWatchedState();
  }

  Future<void> _loadWatchedState() async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    final int? movieId = widget.movie.id;

    if (userId == null || movieId == null) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    try {
      final bool watched = await WatchedCloudService().isWatched(
        userId,
        movieId,
      );

      if (mounted) {
        setState(() {
          _isWatched = watched;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _watchMovie() async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    final int? movieId = widget.movie.id;

    if (userId == null || movieId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please sign in first")));
      return;
    }

    if (_isWatched) {
      return;
    }

    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      await WatchedCloudService().addWatchedMovie(userId, widget.movie);

      final bool refreshedWatched = await WatchedCloudService().isWatched(
        userId,
        movieId,
      );

      if (mounted) {
        setState(() {
          _isWatched = refreshedWatched;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
      }

      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text("Error watching movie: $error")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: UITheme.bgColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.movie.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(image: UITheme.bgImage),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: widget.movie.posterPath == null
                      ? Icon(Icons.movie, size: 48)
                      : Image.network(
                          "https://image.tmdb.org/t/p/w500${widget.movie.posterPath}",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.broken_image, size: 48),
                          width: 250,
                        ),
                ),
                SizedBox(height: 5),
                RatingStars(
                  rating: widget.movie.voteAverage,
                  color: Colors.deepOrangeAccent,
                ),
                SizedBox(height: 5),
                Text(
                  "Release Date: ${widget.movie.releaseDate ?? "Unknown"}",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  widget.movie.overview ?? "No Description",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 10),
                _isLoading
                    ? CircularProgressIndicator()
                    : WideButton(
                        onPressed: _watchMovie,
                        buttonLabel: _isWatched ? "Watch Again" : "Watch",
                        icon: Icons.play_arrow,
                        bgColor: _isWatched ? Colors.teal : Colors.blueAccent,
                        textColor: Colors.white,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
