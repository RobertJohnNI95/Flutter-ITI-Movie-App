import "package:flutter/material.dart";
import "package:flutter_iti_movie_app/database/favorites_db_service.dart";
import "package:flutter_iti_movie_app/models/movie_record.dart";
import "package:flutter_iti_movie_app/services/firebase_auth_service.dart";
import "package:flutter_iti_movie_app/utils/theme.dart";
import "package:flutter_iti_movie_app/views/home_screen.dart";
import "package:flutter_iti_movie_app/views/sign_in_screen.dart";
import "package:flutter_iti_movie_app/widgets/movie_card.dart";
import "package:flutter_iti_movie_app/widgets/wide_button.dart";

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key, required this.userId});
  final String userId;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final UITheme theme = UITheme.instance;
  final FirebaseAuthService auth = FirebaseAuthService();
  late Future<List<MovieRecord>> _favoriteMovies;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    _favoriteMovies = FavoritesDBService.instance.getFavorites(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.bgColor,
        title: Text("FAVORITE MOVIES"),
      ),
      drawer: Drawer(
        backgroundColor: theme.bgColor.withValues(alpha: 0.8),
        width: 200,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 100),
              WideButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HomeScreen(userId: auth.currentUser!.uid),
                    ),
                  );
                },
                buttonLabel: "Home",
                icon: Icons.home,
              ),
              SizedBox(height: 5),
              WideButton(
                bgColor: Colors.teal,
                textColor: Colors.white,
                onPressed: () {},
                buttonLabel: "Favorite Movies",
                icon: Icons.favorite,
              ),
              SizedBox(height: 5),
              WideButton(
                onPressed: () {},
                buttonLabel: "Watched Movies",
                icon: Icons.check,
              ),
              SizedBox(height: 5),
              Divider(),
              WideButton(
                buttonLabel: "Sign Out",
                onPressed: () async {
                  await auth.signOut();
                  Navigator.pushReplacement(
                    // ignore: use_build_context_synchronously
                    context,
                    MaterialPageRoute(builder: (_) => SignInScreen()),
                  );
                },
                bgColor: Colors.red,
                textColor: Colors.white,
                icon: Icons.logout,
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg1.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        width: double.infinity,
        child: SafeArea(
          child: FutureBuilder<List<MovieRecord>>(
            future: _favoriteMovies,
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
