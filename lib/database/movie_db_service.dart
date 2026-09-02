import "package:sqflite/sqflite.dart";
import "package:path/path.dart";
import "package:flutter_iti_movie_app/models/movie_record.dart";
import "package:flutter_iti_movie_app/utils/app_exception.dart";

class MovieDBService {
  static final MovieDBService instance = MovieDBService();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, "movie.db");

      return openDatabase(path, version: 1, onCreate: _createDatabase);
    } catch (_) {
      throw const AppException('Local movie database could not be opened.');
    }
  }

  Future<void> _createDatabase(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE movies (
          id INTEGER PRIMARY KEY,
          title TEXT NOT NULL,
          overview TEXT,
          poster_path TEXT,
          backdrop_path TEXT,
          vote_average REAL NOT NULL DEFAULT 0,
          release_date TEXT
        )
      ''' );
    } catch (_) {
      throw const AppException('Failed to create the local movie table.');
    }
  }

  Future<int> insertMovie(MovieRecord movie) async {
    try {
      final db = await database;
      return db.insert(
        "movies",
        movie.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {
      throw const AppException('Could not save movie locally.');
    }
  }

  Future<List<MovieRecord>> getMovies() async {
    try {
      final db = await database;
      final rows = await db.query("movies", orderBy: "title COLLATE NOCASE");
      return rows.map(MovieRecord.fromMap).toList();
    } catch (_) {
      throw const AppException('Could not read local movies.');
    }
  }

  Future<MovieRecord?> getMovie(int id) async {
    try {
      final db = await database;
      final rows = await db.query(
        "movies",
        where: "id = ?",
        whereArgs: [id],
        limit: 1,
      );
      return rows.isEmpty ? null : MovieRecord.fromMap(rows.first);
    } catch (_) {
      throw const AppException('Could not fetch the selected movie locally.');
    }
  }

  Future<int> deleteMovie(int id) async {
    try {
      final db = await database;
      return db.delete("movies", where: "id = ?", whereArgs: [id]);
    } catch (_) {
      throw const AppException('Could not remove movie from local storage.');
    }
  }

  Future<int> clearMovies() async {
    try {
      final db = await database;
      return db.delete("movies");
    } catch (_) {
      throw const AppException('Could not clear local movie storage.');
    }
  }

  Future<void> close() async {
    try {
      final db = _database;
      if (db != null) {
        await db.close();
        _database = null;
      }
    } catch (_) {
      throw const AppException('Could not close local movie database.');
    }
  }
}
