import "package:flutter/material.dart";
import "package:flutter_iti_movie_app/controller/movie_controller.dart";
import "package:flutter_iti_movie_app/providers/movie_provider.dart";
import "package:flutter_iti_movie_app/services/firebase_auth_service.dart";
import "package:flutter_iti_movie_app/view/screens/sign_in_screen.dart";
import "package:flutter_iti_movie_app/view/widgets/movie_card.dart";
import "package:flutter_iti_movie_app/view/widgets/theme.dart";
import "package:provider/provider.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UITheme theme = UITheme.instance;
  final FirebaseAuthService auth = FirebaseAuthService();
  late final MovieProvider movieProvider;
  late final MovieController movieController;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    movieProvider = MovieProvider();
    movieController = MovieController(provider: movieProvider);
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    try {
      await movieController.loadMovies();
    } catch (error) {
      if (mounted) {
        setState(() => _loadError = error.toString());
      }
    }
  }

  @override
  void dispose() {
    movieProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.bgColor,
        leading: IconButton(
          onPressed: () async {
            await auth.signOut();
            Navigator.pushReplacement(
              // ignore: use_build_context_synchronously
              context,
              MaterialPageRoute(builder: (_) => SignInScreen()),
            );
          },
          icon: Icon(Icons.logout, color: Colors.red),
        ),
        title: Text("WELCOME"),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg1.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        width: double.infinity,
        child: ChangeNotifierProvider.value(
          value: movieProvider,
          child: Consumer<MovieProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading && provider.movies.isEmpty) {
                return Center(child: CircularProgressIndicator());
              }

              if (_loadError != null) {
                return _ErrorMessage(
                  message: _loadError!,
                  onRetry: _loadMovies,
                );
              }

              if (provider.errorMessage != null) {
                return _ErrorMessage(
                  message: provider.errorMessage!,
                  onRetry: _loadMovies,
                );
              }

              if (provider.movies.isEmpty) {
                return Center(child: Text("No movies found"));
              }

              return GridView.builder(
                padding: EdgeInsets.all(8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.62,
                ),
                itemCount: provider.movies.length,
                itemBuilder: (context, index) {
                  final movie = provider.movies[index];
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
