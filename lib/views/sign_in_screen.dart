import "package:flutter/material.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter_iti_movie_app/services/firebase_auth_service.dart";
import "package:flutter_iti_movie_app/views/home_screen.dart";
import "package:flutter_iti_movie_app/views/sign_up_screen.dart";
import "package:flutter_iti_movie_app/utils/theme.dart";
import "package:flutter_iti_movie_app/widgets/wide_button.dart";

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final UITheme theme = UITheme.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  bool obscurePass = true;
  bool _isLoading = false;
  final FirebaseAuthService auth = FirebaseAuthService();

  Future<void> signIn() async {
    final String email = emailController.text;
    final String pass = passController.text;

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Empty email or password field.")));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await auth.signIn(email: email, password: pass);
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(userId: auth.currentUser!.uid),
        ),
      );
    } on FirebaseAuthException catch (error) {
      final message = switch (error.code) {
        "invalid-credential" ||
        "user-not-found" ||
        "wrong-password" => "Invalid email address or password",
        "invalid-email" => "Please enter a valid email address",
        "too-many-requests" => "Too many attempts. Try again later.",
        _ => "Sign-in failed. Please try again.",
      };
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: theme.bgColor, title: Text("SIGN IN")),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg1.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Sign in to your account",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "If you don't have an account, ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => SignUpScreen()),
                        );
                      },
                      child: Text(
                        "sign up.",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                      labelText: "Email",
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextField(
                    controller: passController,
                    obscureText: obscurePass,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.password),
                      labelText: "Password",
                      suffixIcon: IconButton(
                        icon: (obscurePass)
                            ? Icon(Icons.visibility)
                            : Icon(Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            obscurePass = !obscurePass;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: _isLoading
                      ? CircularProgressIndicator(strokeWidth: 2)
                      : WideButton(
                          onPressed: signIn,
                          buttonLabel: "SIGN IN",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
