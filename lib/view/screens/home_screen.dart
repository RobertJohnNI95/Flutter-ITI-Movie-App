import "package:flutter/material.dart";
import "package:flutter_iti_movie_app/service/firebase_auth_service.dart";
import "package:flutter_iti_movie_app/view/screens/sign_in_screen.dart";

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final FirebaseAuthService auth = FirebaseAuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        leading: IconButton(
          onPressed: () async {
            await auth.signOut();
            Navigator.pushReplacement(
              // ignore: use_build_context_synchronously
              context,
              MaterialPageRoute(builder: (_) => SignInScreen()),
            );
          },
          icon: Icon(Icons.logout, color: Colors.red),
        ),
        title: Text("WELCOME"),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg1.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        width: double.infinity,
        child: Center(child: Text("You are now signed in")),
      ),
    );
  }
}
