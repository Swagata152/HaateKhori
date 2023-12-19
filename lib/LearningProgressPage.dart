import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alphabetlearning/GlobalVariables.dart'; // Adjust this import based on your actual file structure

class LearningProgressPage extends StatefulWidget {
  @override
  _LearningProgressPageState createState() => _LearningProgressPageState();
}

class _LearningProgressPageState extends State<LearningProgressPage> {
  Future<int> getQuizCount() async {
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('quizzes').get();
    print('Quiz count: ${querySnapshot.size}');
    return querySnapshot.size;
  }

  @override
  Widget build(BuildContext context) {
    String userId = GlobalVariables().userId; // Access the userId from GlobalVariables

    return Scaffold(
      appBar: AppBar(
        title: Text('Learning Progress'),
      ),
      body: FutureBuilder<int>(
        future: getQuizCount(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == 0) {
            print('No quizzes available');
            return Center(child: Text('No quizzes available'));
          }

          int quizCount = snapshot.data!;
          print('Quiz count: $quizCount');

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('quiz_sessions').doc(userId).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                print('No quiz session data available');
                return Center(child: Text('No quiz session data available'));
              }

              Map<String, dynamic>? quizSessionData = snapshot.data!.data() as Map<String, dynamic>?;

              print('Quiz session data: $quizSessionData');

              if (quizSessionData == null) {
                print('No quiz session data available');
                return Center(child: Text('No quiz session data available'));
              }

              int totalScore = (quizSessionData['score'] ?? 0);

              print('Total Score: $totalScore');

              double progressPercentage = (totalScore / quizCount) * 100;

              print('Progress Percentage: $progressPercentage');

              String motivationalMessage = getMotivationalMessage(progressPercentage);

              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 200, // Set the width to the desired size
                        height: 200, // Set the height to the desired size
                        child: CircularProgressIndicator(
                          value: progressPercentage / 100, // Ensure progress value is between 0 and 1
                          strokeWidth: 10, // Adjust the thickness of the circle
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text('Learning Progress: ${progressPercentage.toStringAsFixed(2)}%'),
                      SizedBox(height: 16),
                      Text('Number of Quizzes: $quizCount'),
                      SizedBox(height: 16),
                      Text('$motivationalMessage'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

String getMotivationalMessage(double progressPercentage) {
  if (progressPercentage >= 40 && progressPercentage < 50) {
    return 'You are doing great! Keep practicing and you will get there!';
  } else if (progressPercentage >= 50 && progressPercentage < 70) {
    return 'Fantastic effort! You are making progress!';
  } else if (progressPercentage >= 70 && progressPercentage < 90) {
    return 'Awesome work! You are getting closer to mastery!';
  } else if (progressPercentage >= 90 && progressPercentage < 100) {
    return 'Incredible! You are almost there! Keep it up!';
  } else if (progressPercentage == 100) {
    return 'Congratulations! You have mastered all the quizzes!';
  } else {
    return 'Do the Quizzes! Every step counts!';
  }
}
