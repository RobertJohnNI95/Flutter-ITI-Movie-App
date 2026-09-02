import "package:sqflite/sqflite.dart";
import "package:path/path.dart";
import "package:flutter_iti_movie_app/models/movie_record.dart";
import "package:flutter_iti_movie_app/utils/app_exception.dart";

class WatchedDBService {
  static final WatchedDBService instance = WatchedDBService();
  Database? _database;

  // MARK:- Get Database
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  // MARK:- Initialize
  Future<Database> _initDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, "watched.db");

      return openDatabase(path, version: 1, onCreate: _createDatabase);
    } catch (_) {
      throw const AppException('Watched list database could not be opened.');
    }
  }

  // MARK:- Create Database
  Future<void> _createDatabase(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE watched (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          movie_id INTEGER NOT NULL,
          user_id TEXT NOT NULL,
          title TEXT NOT NULL,
          overview TEXT,
          poster_path TEXT,
          backdrop_path TEXT,
          vote_average REAL NOT NULL DEFAULT 0,
          release_date TEXT,
          UNIQUE(movie_id, user_id)
        )
      ''' );
    } catch (_) {
      throw const AppException('Failed to create the watched movies table.');
    }
  }

  // MARK:- Insert Watched Movie
  Future<int> insertWatchedMovie(MovieRecord movie, String userId) async {
    try {
      final db = await database;
      return db.insert("watched", {
        'movie_id': movie.id,
        'user_id': userId,
        'title': movie.title,
        'overview': movie.overview,
        'poster_path': movie.posterPath,
        'backdrop_path': movie.backdropPath,
        'vote_average': movie.voteAverage,
        'release_date': movie.releaseDate,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    } catch (_) {
      throw const AppException('Could not save watched movie locally.');
    }
  }

  // MARK:- Get Watched Movies
  Future<List<MovieRecord>> getWatchedMovies(String userId) async {
    try {
      final db = await database;
      final rows = await db.query(
        "watched",
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: "title COLLATE NOCASE",
      );
      return rows
          .map(
            (row) => MovieRecord(
              id: row['movie_id'] as int?,
              title: row['title'] as String,
              overview: row['overview'] as String?,
              posterPath: row['poster_path'] as String?,
              backdropPath: row['backdrop_path'] as String?,
              voteAverage: (row['vote_average'] as num?)?.toDouble() ?? 0,
              releaseDate: row['release_date'] as String?,
            ),
          )
          .toList();
    } catch (_) {
      throw const AppException('Could not load watched movies from local storage.');
    }
  }

  // MARK:- Check if movie watched by user
  Future<bool> isWatched(int movieId, String userId) async {
    try {
      final db = await database;
      final result = await db.query(
        'watched',
        where: 'movie_id = ? AND user_id = ?',
        whereArgs: [movieId, userId],
        limit: 1,
      );
      return result.isNotEmpty;
    } catch (_) {
      throw const AppException('Could not check watched status locally.');
    }
  }

  // MARK:- Remove Movie From Watched Movies List
  Future<int> deleteWatchedMovie(int movieId, String userId) async {
    try {
      final db = await database;
      return db.delete(
        "watched",
        where: "movie_id = ? AND user_id = ?",
        whereArgs: [movieId, userId],
      );
    } catch (_) {
      throw const AppException('Could not remove watched movie from local storage.');
    }
  }
}
