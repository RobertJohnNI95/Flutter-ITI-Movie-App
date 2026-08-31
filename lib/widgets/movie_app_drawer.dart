import "package:flutter/material.dart";
import "package:flutter_iti_movie_app/services/firebase_auth_service.dart";
import "package:flutter_iti_movie_app/utils/theme.dart";
import "package:flutter_iti_movie_app/views/favorites_screen.dart";
import "package:flutter_iti_movie_app/views/home_screen.dart";
import "package:flutter_iti_movie_app/views/sign_in_screen.dart";
import "package:flutter_iti_movie_app/widgets/wide_button.dart";

class MovieAppDrawer extends StatelessWidget {
  MovieAppDrawer({super.key, required this.currentPage});
  final FirebaseAuthService auth = FirebaseAuthService();
  final String currentPage;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: UITheme.bgColor.withValues(alpha: 0.8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 100),
            WideButton(
              bgColor: (currentPage == 'home') ? Colors.teal : null,
              textColor: (currentPage == 'home') ? Colors.white : null,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HomeScreen(userId: auth.currentUser!.uid),
                  ),
                );
              },
              buttonLabel: "Home",
              icon: Icons.home,
            ),
            SizedBox(height: 5),
            WideButton(
              bgColor: (currentPage == 'favorites') ? Colors.teal : null,
              textColor: (currentPage == 'favorites') ? Colors.white : null,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FavoritesScreen(userId: auth.currentUser!.uid),
                  ),
                );
              },
              buttonLabel: "Favorite Movies",
              icon: Icons.favorite,
            ),
            SizedBox(height: 5),
            WideButton(
              bgColor: (currentPage == 'watched') ? Colors.teal : null,
              textColor: (currentPage == 'watched') ? Colors.white : null,
              onPressed: () {},
              buttonLabel: "Watched Movies",
              icon: Icons.movie,
            ),
            SizedBox(height: 5),
            Divider(),
            WideButton(
              buttonLabel: "Sign Out",
              onPressed: () async {
                await auth.signOut();
                Navigator.pushReplacement(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(builder: (_) => SignInScreen()),
                );
              },
              bgColor: Colors.red,
              textColor: Colors.white,
              icon: Icons.logout,
            ),
          ],
        ),
      ),
    );
  }
}
