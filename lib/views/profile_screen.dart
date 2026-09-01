import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter_iti_movie_app/main.dart";
import "package:flutter_iti_movie_app/services/firebase_auth_service.dart";
import "package:flutter_iti_movie_app/utils/theme.dart";
import "package:flutter_iti_movie_app/views/sign_in_screen.dart";
import "package:flutter_iti_movie_app/widgets/movie_app_drawer.dart";
import "package:flutter_iti_movie_app/widgets/wide_button.dart";

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.user});
  final User? user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  late Future<Map<String, dynamic>?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _auth.getUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: UITheme.bgColor, title: Text("PROFILE")),
      drawer: MovieAppDrawer(currentPage: 'profile'),
      body: Container(
        decoration: BoxDecoration(image: UITheme.bgImage),
        width: double.infinity,
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _userFuture,
          builder: ((context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final username = snapshot.data!['username'];
            final email = snapshot.data!['email'];

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: UITheme.bgColor,
                        radius: 50,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        username,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: WideButton(
                        onPressed: () {},
                        buttonLabel: "Edit",
                        icon: Icons.edit,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: WideButton(
                        onPressed: () async {
                          await _auth.signOut();
                          Navigator.pushReplacement(
                            // ignore: use_build_context_synchronously
                            context,
                            MaterialPageRoute(builder: (_) => SignInScreen()),
                          );
                        },
                        buttonLabel: "Sign Out",
                        icon: Icons.logout,
                        bgColor: Colors.red,
                        textColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
