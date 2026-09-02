import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter_iti_movie_app/services/favorite_cloud_service.dart";
import "package:flutter_iti_movie_app/services/firebase_auth_service.dart";
import "package:flutter_iti_movie_app/services/watched_cloud_service.dart";
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
  final FavoriteCloudService _favoriteService = FavoriteCloudService();
  final WatchedCloudService _watchedService = WatchedCloudService();
  late Future<Map<String, dynamic>?> _userFuture;
  late Future<Map<String, int>> _statsFuture;
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userFuture = _auth.getUserDetails();
    _statsFuture = _loadStats();
  }

  Future<Map<String, int>> _loadStats() async {
    final userId = _auth.currentUser?.uid ?? widget.user?.uid;

    if (userId == null || userId.isEmpty) {
      return {'watched': 0, 'favorite': 0};
    }

    final results = await Future.wait([
      _favoriteService.getFavorites(userId),
      _watchedService.getWatchedMovies(userId),
    ]);

    return {
      'favorite': (results[0] as List).length,
      'watched': (results[1] as List).length,
    };
  }

  Widget _buildStatCard(String label, int count, {Icon? icon}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: UITheme.bgColor.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            (icon == null)
                ? Text(
                    count.toString(),
                    style: const TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        count.toString(),
                        style: const TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10),
                      icon,
                    ],
                  ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(backgroundColor: UITheme.bgColor, title: Text("PROFILE")),
      drawer: MovieAppDrawer(currentPage: 'profile'),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(image: UITheme.bgImage),
          width: double.infinity,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 120,
              ),
              child: FutureBuilder<Map<String, dynamic>?>(
                future: _userFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data == null) {
                    return const Center(child: Text("Could not load profile"));
                  }

                  final userData = snapshot.data!;
                  final username = (userData['username'] as String?) ?? "";
                  final email = (userData['email'] as String?) ?? "No email";

                  if (nameController.text.isEmpty && username.isNotEmpty) {
                    nameController.text = username;
                  }

                  return Column(
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
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.edit),
                          ),
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.email),
                          SizedBox(width: 5),
                          Text(
                            email,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      FutureBuilder<Map<String, int>>(
                        future: _statsFuture,
                        builder: (context, statsSnapshot) {
                          final favoriteCount =
                              statsSnapshot.data?['favorite'] ?? 0;
                          final watchedCount =
                              statsSnapshot.data?['watched'] ?? 0;

                          return Row(
                            children: [
                              _buildStatCard(
                                "Watched Movies",
                                watchedCount,
                                icon: Icon(Icons.movie, color: Colors.lime),
                              ),
                              SizedBox(width: 12),
                              _buildStatCard(
                                "Favorite Movies",
                                favoriteCount,
                                icon: Icon(Icons.favorite, color: Colors.red),
                              ),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: WideButton(
                          onPressed: () async {
                            final newUsername = nameController.text.trim();
                            final uid = _auth.currentUser?.uid;

                            if (uid == null || newUsername.isEmpty) {
                              return;
                            }

                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .set({
                                  'email': email,
                                  'username': newUsername,
                                }, SetOptions(merge: true));

                            if (mounted) {
                              setState(() {
                                _userFuture = _auth.getUserDetails();
                              });
                            }
                          },
                          buttonLabel: "Save Username",
                          icon: Icons.save,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: WideButton(
                          onPressed: () async {
                            await _auth.signOut();
                            if (mounted) {
                              Navigator.pushReplacement(
                                // ignore: use_build_context_synchronously
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SignInScreen(),
                                ),
                              );
                            }
                          },
                          buttonLabel: "Sign Out",
                          icon: Icons.logout,
                          bgColor: Colors.red,
                          textColor: Colors.white,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
