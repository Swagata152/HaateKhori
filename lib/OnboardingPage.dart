import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'SignInPage.dart';
import 'FirestoreService.dart';
import 'package:alphabetlearning/GlobalVariables.dart';


class OnboardingPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final FirestoreService firestoreService = FirestoreService();

  Future<void> onboardUser(String username, String name, bool isNewUser, BuildContext context) async {
    try {
      if (isNewUser) {
        if (_usernameController.text.isEmpty || _nameController.text.isEmpty) {
          _showErrorSnackBar(context, 'Please fill in all fields.');
          return;
        }

        bool usernameExists = await firestoreService.doesUsernameExist(username);

        if (usernameExists) {
          _showErrorSnackBar(context, 'Username already exists. Please choose another.');
          return;
        }

        // Register a new user
        await firestoreService.registerUser(username, name);
      }
      GlobalVariables().userId = username;

      // Navigate to the home page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      print('Error onboarding user: $e');
      _showErrorSnackBar(context, 'Error onboarding user. Please try again.');
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
        title: Text('Onboarding'),
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
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_usernameController.text.isEmpty || _nameController.text.isEmpty) {
                  _showErrorSnackBar(context, 'Please fill in all fields.');
                  return;
                }

                bool usernameExists = await firestoreService.doesUsernameExist(_usernameController.text);

                if (usernameExists) {
                  _showErrorSnackBar(context, 'Username already exists. Please choose another.');
                  return;
                }

                // New user, register now
                await onboardUser(_usernameController.text, _nameController.text, true, context);
              },
              child: Text('Start Learning'),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                // Navigate to the Sign In page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignInPage()),
                );
              },
              child: Text('Already have a username? Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}
