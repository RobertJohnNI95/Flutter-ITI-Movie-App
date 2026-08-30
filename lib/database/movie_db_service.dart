import "package:sqflite/sqflite.dart";
import "package:path/path.dart";
import "package:flutter_iti_movie_app/models/movie_record.dart";

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
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "movie.db");

    return openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
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
    ''');
  }

  Future<int> insertMovie(MovieRecord movie) async {
    final db = await database;
    return db.insert(
      "movies",
      movie.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MovieRecord>> getMovies() async {
    final db = await database;
    final rows = await db.query("movies", orderBy: "title COLLATE NOCASE");
    return rows.map(MovieRecord.fromMap).toList();
  }

  Future<MovieRecord?> getMovie(int id) async {
    final db = await database;
    final rows = await db.query(
      "movies",
      where: "id = ?",
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : MovieRecord.fromMap(rows.first);
  }

  Future<int> deleteMovie(int id) async {
    final db = await database;
    return db.delete("movies", where: "id = ?", whereArgs: [id]);
  }

  Future<int> clearMovies() async {
    final db = await database;
    return db.delete("movies");
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
