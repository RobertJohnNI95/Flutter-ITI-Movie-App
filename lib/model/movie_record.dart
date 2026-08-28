class MovieRecord {
  final int? id;
  final String title;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final String? releaseDate;

  const MovieRecord({
    this.id,
    required this.title,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.voteAverage = 0,
    this.releaseDate,
  });

  Map<String, Object?> toMap() {
    return {
      "id": id,
      "title": title,
      "overview": overview,
      "poster_path": posterPath,
      "backdrop_path": backdropPath,
      "vote_average": voteAverage,
      "release_date": releaseDate,
    };
  }

  factory MovieRecord.fromMap(Map<String, Object?> map) {
    return MovieRecord(
      id: map["id"] as int?,
      title: map["title"] as String,
      overview: map["overview"] as String?,
      posterPath: map["poster_path"] as String?,
      backdropPath: map["backdrop_path"] as String?,
      voteAverage: (map["vote_average"] as num?)?.toDouble() ?? 0,
      releaseDate: map["release_date"] as String?,
    );
  }

  factory MovieRecord.fromTmdbJson(Map<String, dynamic> json) {
    return MovieRecord(
      id: json["id"] as int?,
      title: json["title"] as String? ?? "Untitled",
      overview: json["overview"] as String?,
      posterPath: json["poster_path"] as String?,
      backdropPath: json["backdrop_path"] as String?,
      voteAverage: (json["vote_average"] as num?)?.toDouble() ?? 0,
      releaseDate: json["release_date"] as String?,
    );
  }
}
