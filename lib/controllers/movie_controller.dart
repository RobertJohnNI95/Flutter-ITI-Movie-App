import "package:flutter_iti_movie_app/models/movie_record.dart";
import "package:flutter_iti_movie_app/providers/movie_provider.dart";
import "package:flutter_iti_movie_app/services/movie_api_service.dart";

class MovieController {
  final MovieProvider provider;
  final MovieApiService _apiService;

  MovieController({required this.provider, MovieApiService? apiService})
    : _apiService = apiService ?? MovieApiService();

  Future<void> loadMovies() async {
    final movies = await _apiService.getPopularMovies();
    await provider.setMovies(movies);
  }

  Future<void> addMovie(MovieRecord movie) async {
    await provider.addMovie(movie);
  }

  Future<void> deleteMovie(int id) async {
    await provider.deleteMovie(id);
  }

  Future<void> clearMovies() async {
    await provider.clearMovies();
  }

  MovieRecord? findMovie(int id) {
    for (final movie in provider.movies) {
      if (movie.id == id) {
        return movie;
      }
    }
    return null;
  }

  List<MovieRecord> searchMovies(String searchWord) {
    final query = searchWord.trim();
    if (query.isEmpty) {
      return List<MovieRecord>.from(provider.movies);
    }

    final lowerQuery = query.toLowerCase();
    return provider.movies.where((movie) {
      final title = movie.title.toLowerCase();
      final overview = (movie.overview ?? "").toLowerCase();
      final releaseDate = (movie.releaseDate ?? "").toLowerCase();
      return title.contains(lowerQuery) ||
          overview.contains(lowerQuery) ||
          releaseDate.contains(lowerQuery);
    }).toList();
  }
}
