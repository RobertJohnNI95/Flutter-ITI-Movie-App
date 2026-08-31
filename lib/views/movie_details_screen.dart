import "package:flutter/material.dart";
import "package:flutter_iti_movie_app/models/movie_record.dart";
import "package:flutter_iti_movie_app/utils/theme.dart";

class MovieDetailsScreen extends StatelessWidget {
  MovieDetailsScreen({super.key, required this.movie});
  final MovieRecord movie;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: UITheme.bgColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(movie.title, style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(image: UITheme.bgImage),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: movie.posterPath == null
                      ? Icon(Icons.movie, size: 48)
                      : Image.network(
                          "https://image.tmdb.org/t/p/w500${movie.posterPath}",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.broken_image, size: 48),
                          width: 250,
                        ),
                ),
                SizedBox(height: 5),
                // RatingStars(stars: movie.voteAverage),
                SizedBox(height: 5),
                Text(
                  "Release Date: ${movie.releaseDate ?? "Unknown"}",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  movie.overview ?? "No Description",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
