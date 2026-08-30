import "package:sqflite/sqflite.dart";
import "package:path/path.dart";
import "package:flutter_iti_movie_app/models/movie_record.dart";

class FavoritesDBService {
  static final FavoritesDBService instance = FavoritesDBService();
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
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "favorite.db");

    return openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  // MARK:- Create Database
  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favorites (
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
    ''');
  }

  // MARK:- Insert Favorite
  Future<int> insertFavorite(MovieRecord movie, String userId) async {
    final db = await database;
    return db.insert("favorites", {
      'movie_id': movie.id,
      'user_id': userId,
      'title': movie.title,
      'overview': movie.overview,
      'poster_path': movie.posterPath,
      'backdrop_path': movie.backdropPath,
      'vote_average': movie.voteAverage,
      'release_date': movie.releaseDate,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  // Get Favorites
  Future<List<MovieRecord>> getFavorites(String userId) async {
    final db = await database;
    final rows = await db.query(
      "favorites",
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
  }

  // MARK:- Check if movie is user's
  Future<bool> isFavorite(int movieId, String userId) async {
    final db = await database;
    final result = await db.query(
      'favorites',
      where: 'movie_id = ? AND user_id = ?',
      whereArgs: [movieId, userId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  // MARK:- Remove Favorite
  Future<int> deleteFavorite(int movieId, String userId) async {
    final db = await database;
    return db.delete(
      "favorites",
      where: "movie_id = ? AND user_id = ?",
      whereArgs: [movieId, userId],
    );
  }
}
