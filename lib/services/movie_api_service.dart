import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_iti_movie_app/models/movie_record.dart';
import 'package:flutter_iti_movie_app/utils/app_exception.dart';

class MovieApiService {
  static const _baseUrl = 'https://api.themoviedb.org/3';
  static const _accessToken =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIxOGExYWEwYTIzMGZkZDYxZGI1OWQ5MWFiMTM0OGY0ZiIsIm5iZiI6MTc4NzkwNjE0NC42ODk5OTk4LCJzdWIiOiI2YTkxNDg2MDZkNzNiNzFiZDU4NGI4MjYiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.VLipDJ1FtePulO7vcWEBOD1WctXxIBiQv7o26erZSu8';

  Future<List<MovieRecord>> getPopularMovies() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/movie/popular'),
            headers: {
              'Authorization': 'Bearer $_accessToken',
              'accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw AppException(
          'Unable to load movies right now. Please try again later.',
          code: 'tmdb-http-${response.statusCode}',
        );
      }

      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) {
        throw const AppException('Movie data received was invalid.');
      }

      final results = data['results'] as List<dynamic>? ?? [];
      return results
          .map(
            (movie) => MovieRecord.fromTmdbJson(movie as Map<String, dynamic>),
          )
          .toList();
    } on TimeoutException {
      throw const AppException(
        'The movie service timed out. Please try again.',
      );
    } on FormatException {
      throw const AppException(
        'The movie response was malformed. Please try again.',
      );
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException(
        'Could not load movies. Please check your connection.',
      );
    }
  }
}
