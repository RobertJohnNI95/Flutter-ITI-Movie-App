import "package:flutter/material.dart";
import "package:flutter_iti_movie_app/controller/movie_controller.dart";
import "package:flutter_iti_movie_app/model/movie_record.dart";
import "package:flutter_iti_movie_app/providers/movie_provider.dart";
import "package:flutter_iti_movie_app/view/widgets/movie_card.dart";
import "package:flutter_iti_movie_app/view/widgets/theme.dart";
import "package:provider/provider.dart";

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.movieProvider, this.searchWord});

  final MovieProvider movieProvider;
  final String? searchWord;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final UITheme theme = UITheme.instance;
  final TextEditingController _searchController = TextEditingController();
  late final MovieController movieController;
  List<MovieRecord> _filteredMovies = [];

  @override
  void initState() {
    super.initState();
    movieController = MovieController(provider: widget.movieProvider);
    _searchController.text = widget.searchWord ?? "";
    _performSearch(widget.searchWord ?? "");
  }

  void _performSearch(String query) {
    final searchedMovies = movieController.searchMovies(query);
    setState(() => _filteredMovies = searchedMovies);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.bgColor,
        title: Text("${_searchController.text} SEARCH RESULTS"),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg1.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        width: double.infinity,
        child: SafeArea(
          child: Column(
            children: [
              /*
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: _searchController,
                  onSubmitted: _performSearch,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: "Search movies",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => _performSearch(_searchController.text),
                    ),
                  ),
                ),
              ),
              */
              Expanded(
                child: ChangeNotifierProvider.value(
                  value: widget.movieProvider,
                  child: Consumer<MovieProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading && provider.movies.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (provider.errorMessage != null) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(provider.errorMessage!),
                          ),
                        );
                      }

                      final movies = _searchController.text.trim().isEmpty
                          ? provider.movies
                          : _filteredMovies;

                      if (movies.isEmpty) {
                        final query = _searchController.text.trim();
                        return Center(
                          child: Text(
                            query.isEmpty
                                ? "No movies found"
                                : "No movies found for '$query'",
                          ),
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
                          return MovieCard(movie: movie);
                        },
                      );
                    },
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
