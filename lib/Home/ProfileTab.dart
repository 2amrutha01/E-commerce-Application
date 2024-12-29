import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfileTab extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    // Get the current user
    User? user = _auth.currentUser;

    // If the user is not signed in, show sign-in button
    if (user == null) {
      return Center(
        child: ElevatedButton(
          onPressed: () async {
            // Google sign-in
            GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
            if (googleUser != null) {
              GoogleSignInAuthentication googleAuth =
                  await googleUser.authentication;
              // Sign in with Firebase
              await _auth.signInWithCredential(GoogleAuthProvider.credential(
                accessToken: googleAuth.accessToken,
                idToken: googleAuth.idToken,
              ));
            }
          },
          child: Text("Sign In with Google"),
        ),
      );
    }

    // Display user details if signed in
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Display profile image
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(user.photoURL ?? ''),
              ),
              SizedBox(height: 20),
              // Display user's name
              Text(
                'Name: ${user.displayName ?? 'No Name'}',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 10),
              // Display user's email
              Text(
                'Email: ${user.email ?? 'No Email'}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              // Display user's phone number (if available)

              SizedBox(height: 20),
              // View My Orders Button
              ElevatedButton(
                onPressed: () {
                  // Navigate to Orders screen (ensure '/orders' is defined in routes)
                  // Navigator.pushNamed(context,
                  //     '/orders'); // Replace '/orders' with the correct route if needed
                },
                child: Text("View My Orders"),
              ),
              SizedBox(height: 20),
              // Sign-out button
              ElevatedButton(
                onPressed: () {
                  // Show confirmation alert dialog before sign out
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Confirm Sign Out"),
                        content: Text("Are you sure you want to sign out?"),
                        actions: <Widget>[
                          // No action, just close the dialog
                          TextButton(
                            child: Text("No"),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          // Proceed with sign out if "Yes" clicked
                          TextButton(
                            child: Text("Yes"),
                            onPressed: () async {
                              await _googleSignIn.signOut();
                              await _auth.signOut();
                              Navigator.pushReplacementNamed(
                                  context, '/login'); // Navigate to login page
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text("Sign Out"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
