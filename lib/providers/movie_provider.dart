import "package:flutter/foundation.dart";
import "package:flutter_iti_movie_app/models/movie_record.dart";
import "package:flutter_iti_movie_app/database/movie_db_service.dart";

class MovieProvider extends ChangeNotifier {
  MovieProvider({MovieDBService? databaseService})
    : _databaseService = databaseService ?? MovieDBService.instance;

  final MovieDBService _databaseService;
  List<MovieRecord> _movies = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<MovieRecord> get movies => List.unmodifiable(_movies);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadMovies() async {
    await _runDatabaseOperation(() async {
      _movies = await _databaseService.getMovies();
    });
  }

  Future<void> setMovies(List<MovieRecord> movies) async {
    await _runDatabaseOperation(() async {
      for (final movie in movies) {
        await _databaseService.insertMovie(movie);
      }
      _movies = await _databaseService.getMovies();
    });
  }

  Future<void> addMovie(MovieRecord movie) async {
    await _runDatabaseOperation(() async {
      final movieId = await _databaseService.insertMovie(movie);
      final savedMovie = movie.id == movieId
          ? movie
          : MovieRecord(
              id: movieId,
              title: movie.title,
              overview: movie.overview,
              posterPath: movie.posterPath,
              backdropPath: movie.backdropPath,
              voteAverage: movie.voteAverage,
              releaseDate: movie.releaseDate,
            );

      _movies = [
        ..._movies.where((currentMovie) => currentMovie.id != savedMovie.id),
        savedMovie,
      ];
    });
  }

  Future<void> deleteMovie(int id) async {
    await _runDatabaseOperation(() async {
      await _databaseService.deleteMovie(id);
      _movies = _movies.where((movie) => movie.id != id).toList();
    });
  }

  Future<void> clearMovies() async {
    await _runDatabaseOperation(() async {
      await _databaseService.clearMovies();
      _movies = [];
    });
  }

  Future<void> _runDatabaseOperation(Future<void> Function() operation) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await operation();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
