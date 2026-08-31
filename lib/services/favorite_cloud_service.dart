import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_iti_movie_app/database/favorites_db_service.dart';
import 'package:flutter_iti_movie_app/models/movie_record.dart';

class FavoriteCloudService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<T> _runWithFallback<T>({
    required Future<T> Function() remote,
    required Future<T> Function() local,
    Duration timeout = const Duration(seconds: 6),
  }) async {
    try {
      return await remote().timeout(timeout);
    } on TimeoutException {
      return await local();
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable' || e.code == 'offline') {
        return await local();
      }
      rethrow;
    }
  }

  Future<void> addFavorite(String userId, MovieRecord movie) async {
    await _runWithFallback<void>(
      remote: () async {
        await _db
            .collection('users')
            .doc(userId)
            .collection('favorites')
            .doc(movie.id.toString())
            .set({
              'movieId': movie.id,
              'title': movie.title,
              'overview': movie.overview,
              'posterPath': movie.posterPath,
              'backdropPath': movie.backdropPath,
              'voteAverage': movie.voteAverage,
              'releaseDate': movie.releaseDate,
              'createdAt': FieldValue.serverTimestamp(),
            });
        return;
      },
      local: () async {
        await FavoritesDBService.instance.insertFavorite(movie, userId);
        return;
      },
    );
  }

  List<MovieRecord> _mapFavoriteDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return docs.map((doc) {
      final data = doc.data();

      return MovieRecord(
        id: data['movieId'] as int?,
        title: data['title'] as String? ?? '',
        overview: data['overview'] as String?,
        posterPath: data['posterPath'] as String?,
        backdropPath: data['backdropPath'] as String?,
        voteAverage: (data['voteAverage'] as num?)?.toDouble() ?? 0,
        releaseDate: data['releaseDate'] as String?,
      );
    }).toList();
  }

  Future<List<MovieRecord>> getFavorites(String userId) async {
    return _runWithFallback<List<MovieRecord>>(
      remote: () async {
        final snapshot = await _db
            .collection('users')
            .doc(userId)
            .collection('favorites')
            .get();

        return _mapFavoriteDocs(snapshot.docs);
      },
      local: () => FavoritesDBService.instance.getFavorites(userId),
    );
  }

  Stream<List<MovieRecord>> favoritesStream(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .map((snapshot) => _mapFavoriteDocs(snapshot.docs));
  }

  Future<bool> isFavorite(String userId, int movieId) async {
    return _runWithFallback<bool>(
      remote: () async {
        final doc = await _db
            .collection('users')
            .doc(userId)
            .collection('favorites')
            .doc(movieId.toString())
            .get();

        return doc.exists;
      },
      local: () => FavoritesDBService.instance.isFavorite(movieId, userId),
    );
  }

  Future<void> deleteFavorite(String userId, int movieId) async {
    await _runWithFallback<void>(
      remote: () async {
        await _db
            .collection('users')
            .doc(userId)
            .collection('favorites')
            .doc(movieId.toString())
            .delete();
        return;
      },
      local: () async {
        await FavoritesDBService.instance.deleteFavorite(movieId, userId);
        return;
      },
    );
  }
}
