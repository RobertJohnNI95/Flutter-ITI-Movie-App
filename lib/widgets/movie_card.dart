import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter_iti_movie_app/models/movie_record.dart";
import "package:flutter_iti_movie_app/services/favorite_cloud_service.dart";
import "package:flutter_iti_movie_app/views/movie_details_screen.dart";

class MovieCard extends StatefulWidget {
  const MovieCard({super.key, required this.movie});
  final MovieRecord movie;

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  bool _isFavorite = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteState();
  }

  Future<void> _loadFavoriteState() async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    final int? movieId = widget.movie.id;

    if (userId == null || movieId == null) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    final bool favorite = await FavoriteCloudService().isFavorite(
      userId,
      movieId,
    );

    if (mounted) {
      setState(() {
        _isFavorite = favorite;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    final int? movieId = widget.movie.id;

    if (userId == null || movieId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please sign in first")));
      return;
    }

    final bool originalState = _isFavorite;
    final bool nextState = !originalState;

    if (mounted) {
      setState(() {
        _isFavorite = nextState;
        _isLoading = true;
      });
    }

    try {
      if (nextState) {
        await FavoriteCloudService().addFavorite(userId, widget.movie);
      } else {
        await FavoriteCloudService().deleteFavorite(userId, movieId);
      }

      final bool refreshedFavorite = await FavoriteCloudService().isFavorite(
        userId,
        movieId,
      );

      if (mounted) {
        setState(() {
          _isFavorite = refreshedFavorite;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isFavorite = originalState;
          _isLoading = false;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not update favorite: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MovieDetailsScreen(movie: widget.movie),
          ),
        );
      },
      child: Card(
        color: Colors.blueAccent.withValues(alpha: 0.3),
        elevation: 5,
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: AspectRatio(
                    aspectRatio: 0.67,
                    child: widget.movie.posterPath == null
                        ? Icon(Icons.movie, size: 48)
                        : Image.network(
                            "https://image.tmdb.org/t/p/w500${widget.movie.posterPath}",
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.broken_image, size: 48),
                          ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  widget.movie.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                widget.movie.releaseDate ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 4, bottom: 8),
                child: _isLoading
                    ? CircularProgressIndicator()
                    : IconButton(
                        onPressed: _toggleFavorite,
                        icon: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_outline,
                          color: _isFavorite ? Colors.red : Colors.black,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
