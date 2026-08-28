import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_iti_movie_app/model/movie_record.dart';

class MovieApiService {
  static const _baseUrl = 'https://api.themoviedb.org/3';
  static const _accessToken =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIxOGExYWEwYTIzMGZkZDYxZGI1OWQ5MWFiMTM0OGY0ZiIsIm5iZiI6MTc4NzkwNjE0NC42ODk5OTk4LCJzdWIiOiI2YTkxNDg2MDZkNzNiNzFiZDU4NGI4MjYiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.VLipDJ1FtePulO7vcWEBOD1WctXxIBiQv7o26erZSu8';

  Future<List<MovieRecord>> getPopularMovies({int page = 1}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/movie/popular?page=$page'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'TMDB request failed: ${response.statusCode} ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>? ?? [];
    return results
        .map((movie) => MovieRecord.fromTmdbJson(movie as Map<String, dynamic>))
        .toList();
  }
}
