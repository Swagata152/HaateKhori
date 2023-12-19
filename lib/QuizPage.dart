import 'package:alphabetlearning/GlobalVariables.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'HomePage.dart';

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Map<String, dynamic>> quizQuestions = [];
  int currentQuestionIndex = 0;
  int correctAnswers = 0;

  @override
  void initState() {
    super.initState();
    fetchQuizQuestions();
  }

  Future<void> fetchQuizQuestions() async {
    try {
      final quizSnapshot =
      await FirebaseFirestore.instance.collection('quizzes').get();

      setState(() {
        quizQuestions = quizSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      print('Error fetching quiz questions: $e');
    }
  }

  void checkAnswer(bool selectedAnswer) {
    bool correctAnswer = quizQuestions[currentQuestionIndex]['correctAnswer'];
    String correctionMessage =
    quizQuestions[currentQuestionIndex]['correctionMessage'];

    int scoreChange = selectedAnswer == correctAnswer ? 1 : 0;

    setState(() {
      correctAnswers += scoreChange;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              selectedAnswer == correctAnswer ? 'Correct!' : 'Incorrect!'),
          content: Column(
            children: [
              Text(correctionMessage),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  moveToNextQuestion();
                },
                child: Text('Next Question'),
              ),
            ],
          ),
        );
      },
    );
  }

  void moveToNextQuestion() {
    if (currentQuestionIndex < quizQuestions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      // Quiz completed, show results and update score
      updateQuizSessionScore(correctAnswers);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Quiz Completed'),
            content: Text('Correct Answers: $correctAnswers'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the current dialog
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()), // Navigate to the home page
                  );
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void updateQuizSessionScore(int score) {
    String userId = GlobalVariables().userId; // Replace with the actual user ID

    FirebaseFirestore.instance.collection('quiz_sessions').doc(userId).get().then(
          (docSnapshot) {
        if (docSnapshot.exists) {

          FirebaseFirestore.instance
              .collection('quiz_sessions')
              .doc(userId)
              .update({
            'score': score,
          });
        } else {
          FirebaseFirestore.instance
              .collection('quiz_sessions')
              .doc(userId)
              .set({
            'score': score,
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (quizQuestions.isEmpty) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    Map<String, dynamic> currentQuestion = quizQuestions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              currentQuestion['question'],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Image.network(
              currentQuestion['imageUrl'],
              height: 200,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    checkAnswer(true);
                  },
                  child: Text('True'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    checkAnswer(false);
                  },
                  child: Text('False'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
