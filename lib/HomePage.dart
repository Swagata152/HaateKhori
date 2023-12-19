import 'package:alphabetlearning/Alphabet.dart';
import 'package:alphabetlearning/AnimalPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:alphabetlearning/LearningProgressPage.dart';
import 'package:alphabetlearning/QuizPage.dart';
import 'package:alphabetlearning/LeaderboardPage.dart';
import 'OnboardingPage.dart';
import 'SignInPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget selectedOption({
    required String image,
    required String name,
  }) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.grey, width: 2)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 60,
            decoration:
            BoxDecoration(image: DecorationImage(image: AssetImage(image))),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            name,
            style: TextStyle(fontSize: 17),
          ),
        ],
      ),
    );
  }

  void signOut() {
    // Perform sign out logic here

    // Navigate to the onboarding or sign-in page
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => OnboardingPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Set this property to false to hide the back button
        elevation: 0.0,
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(
          "Home Page",
          style: TextStyle(
            fontSize: 23,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // Sign out when the button is pressed
              signOut();
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: Container(
        child: Container(
          height: 800,
          width: double.infinity,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              )),
          child: ListView(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Option',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 20,
                      ),
                      child: Container(
                        height: 300,
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.30,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => alphabet(),
                                  ),
                                );
                              },
                              child: selectedOption(
                                image: 'assets/alphabet.png',
                                name: 'Alphabet',
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AnimalPage(),
                                  ),
                                );
                              },
                              child: selectedOption(
                                image: 'assets/animal.png',
                                name: 'Animal',
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                // Show bottom sheet with learning progress options
                                showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Container(
                                      padding: EdgeInsets.all(16),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            title: Text('Learning Progress'),
                                            onTap: () {
                                              Navigator.pop(context);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      LearningProgressPage(),
                                                ),
                                              );
                                            },
                                          ),
                                          ListTile(
                                            title: Text('Leaderboard'),
                                            onTap: () {
                                              Navigator.pop(context);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      LeaderboardPage(),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              child: selectedOption(
                                image: 'assets/progress.png',
                                name: 'Learning Progress',
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => QuizPage(),
                                  ),
                                );
                              },
                              child: selectedOption(
                                image: 'assets/quiz.png', // Replace with your quiz image
                                name: 'Quiz',
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
