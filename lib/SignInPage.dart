import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'FirestoreService.dart';
import 'package:alphabetlearning/GlobalVariables.dart';

class SignInPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController(); // Added password controller
  final FirestoreService firestoreService = FirestoreService();

  Future<void> signInUser(String username, String password, BuildContext context) async {
    try {
      if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
        _showErrorSnackBar(context, 'Please enter your username and password.');
        return;
      }

      bool usernameExists = await firestoreService.doesUsernameExist(username);

      if (!usernameExists) {
        _showErrorSnackBar(context, 'Username not found. Please check your username.');
        return;
      }

      // Validate the password
      bool passwordCorrect = await firestoreService.isPasswordCorrect(username, password);

      if (!passwordCorrect) {
        _showErrorSnackBar(context, 'Incorrect password. Please try again.');
        return;
      }

      GlobalVariables().userId = username;
      // Existing user, sign in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      print('Error signing in user: $e');
      _showErrorSnackBar(context, 'Error signing in. Please try again.');
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
                  _showErrorSnackBar(context, 'Please enter your username and password.');
                  return;
                }

                // Sign in the user based on the entered username and password
                await signInUser(_usernameController.text, _passwordController.text, context);
              },
              child: Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}
