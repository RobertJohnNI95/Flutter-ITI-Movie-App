import "package:flutter/material.dart";
import "package:flutter_iti_movie_app/models/movie_record.dart";
import "package:flutter_iti_movie_app/services/watched_cloud_service.dart";
import "package:flutter_iti_movie_app/utils/theme.dart";
import "package:flutter_iti_movie_app/widgets/movie_app_drawer.dart";
import "package:flutter_iti_movie_app/widgets/movie_card.dart";

class WatchedScreen extends StatefulWidget {
  const WatchedScreen({super.key, required this.userId});
  final String userId;

  @override
  State<WatchedScreen> createState() => _WatchedScreenState();
}

class _WatchedScreenState extends State<WatchedScreen> {
  late final Stream<List<MovieRecord>> _watchedMoviesStream;

  @override
  void initState() {
    super.initState();
    _watchedMoviesStream = WatchedCloudService().watchedMovieStream(
      widget.userId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: UITheme.bgColor,
        title: Text("WATCHED MOVIES"),
      ),
      drawer: MovieAppDrawer(currentPage: 'watched'),
      body: Container(
        decoration: BoxDecoration(image: UITheme.bgImage),
        width: double.infinity,
        child: Column(
          children: [
            Text("Tap and hold on a movie to remove it from list"),
            Expanded(
              child: SafeArea(
                child: StreamBuilder<List<MovieRecord>>(
                  stream: _watchedMoviesStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }

                    final movies = snapshot.data ?? [];

                    if (movies.isEmpty) {
                      return Center(
                        child: Text("No watched movies in your list"),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.62,
                          ),
                      itemCount: movies.length,
                      itemBuilder: (context, index) {
                        final movie = movies[index];
                        return MovieCard(
                          movie: movie,
                          onRemoveWatched: () async {
                            await WatchedCloudService().deleteWatchedMovie(
                              widget.userId,
                              movie.id ?? -1,
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
