import "package:flutter/material.dart";

class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.color = Colors.amber,
  });
  final double rating;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            (rating >= 2)
                ? Icons.star
                : (rating >= 1)
                ? Icons.star_half
                : Icons.star_border,
            color: color,
          ),
          SizedBox(width: 5),
          Icon(
            (rating >= 4)
                ? Icons.star
                : (rating >= 3)
                ? Icons.star_half
                : Icons.star_border,
            color: color,
          ),
          SizedBox(width: 5),
          Icon(
            (rating >= 6)
                ? Icons.star
                : (rating >= 5)
                ? Icons.star_half
                : Icons.star_border,
            color: color,
          ),
          SizedBox(width: 5),
          Icon(
            (rating >= 8)
                ? Icons.star
                : (rating >= 7)
                ? Icons.star_half
                : Icons.star_border,
            color: color,
          ),
          SizedBox(width: 5),
          Icon(
            (rating == 10)
                ? Icons.star
                : (rating >= 9)
                ? Icons.star_half
                : Icons.star_border,
            color: color,
          ),
        ],
      ),
    );
  }
}
