import "package:flutter/material.dart";
import "package:flutter_iti_movie_app/model/movie_record.dart";
import "package:flutter_iti_movie_app/view/screens/movie_details_screen.dart";

class MovieCard extends StatelessWidget {
  const MovieCard({super.key, required this.movie});
  final MovieRecord movie;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MovieDetailsScreen(movie: movie)),
        );
      },
      child: Card(
        color: Colors.blueAccent.withValues(alpha: 0.3),
        elevation: 5,
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: AspectRatio(
                    aspectRatio: 0.67,
                    child: movie.posterPath == null
                        ? Icon(Icons.movie, size: 48)
                        : Image.network(
                            "https://image.tmdb.org/t/p/w500${movie.posterPath}",
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.broken_image, size: 48),
                          ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  movie.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                movie.releaseDate ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 4, bottom: 8),
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.favorite_outline),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
