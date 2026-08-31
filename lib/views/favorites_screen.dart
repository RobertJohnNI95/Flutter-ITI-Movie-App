import "package:flutter/material.dart";
import "package:flutter_iti_movie_app/models/movie_record.dart";
import "package:flutter_iti_movie_app/services/favorite_cloud_service.dart";
import "package:flutter_iti_movie_app/services/firebase_auth_service.dart";
import "package:flutter_iti_movie_app/utils/theme.dart";
import "package:flutter_iti_movie_app/widgets/movie_app_drawer.dart";
import "package:flutter_iti_movie_app/widgets/movie_card.dart";

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key, required this.userId});
  final String userId;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FirebaseAuthService auth = FirebaseAuthService();
  late final Stream<List<MovieRecord>> _favoriteMoviesStream;

  @override
  void initState() {
    super.initState();
    _favoriteMoviesStream = FavoriteCloudService().favoritesStream(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: UITheme.bgColor,
        title: Text("FAVORITE MOVIES"),
      ),
      drawer: MovieAppDrawer(currentPage: 'favorites'),
      body: Container(
        decoration: BoxDecoration(image: UITheme.bgImage),
        width: double.infinity,
        child: SafeArea(
          child: StreamBuilder<List<MovieRecord>>(
            stream: _favoriteMoviesStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              final movies = snapshot.data ?? [];

              if (movies.isEmpty) {
                return Center(child: Text("No movies in your favorites list"));
              }

              return GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.62,
                ),
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  return MovieCard(movie: movie);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Could not load movies"),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(message, textAlign: TextAlign.center),
          ),
          ElevatedButton(onPressed: onRetry, child: Text("Retry")),
        ],
      ),
    );
  }
}
