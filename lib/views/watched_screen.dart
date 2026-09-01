import "package:flutter/material.dart";
import "package:flutter_iti_movie_app/utils/theme.dart";
import "package:flutter_iti_movie_app/widgets/movie_app_drawer.dart";

class WatchedScreen extends StatefulWidget {
  const WatchedScreen({super.key, required this.userId});
  final String userId;

  @override
  State<WatchedScreen> createState() => _WatchedScreenState();
}

class _WatchedScreenState extends State<WatchedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: UITheme.bgColor,
        title: Text("WATCHED MOVIES"),
      ),
      drawer: MovieAppDrawer(currentPage: 'watched'),
      body: Container(
        decoration: BoxDecoration(image: UITheme.bgImage),
        width: double.infinity,
        child: SafeArea(child: Placeholder()),
      ),
    );
  }
}
