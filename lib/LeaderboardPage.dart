import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardPage extends StatefulWidget {
  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('quiz_sessions').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          List<QueryDocumentSnapshot<Map<String, dynamic>>>? quizSessions = snapshot.data?.docs;

          if (quizSessions == null) {
            return Center(
              child: Text('No data available'),
            );
          }

          // Calculate total scores and sort by scores
          quizSessions?.sort((a, b) {
            int totalScoreA = (a['score'] ?? 0) ;
            int totalScoreB = (b['score'] ?? 0) ;

            return totalScoreB.compareTo(totalScoreA);
          });

          return ListView.builder(
            itemCount: quizSessions.length,
            itemBuilder: (context, index) {
              String? userId = quizSessions[index].id;
              int position = index + 1;

              return ListTile(
                title: Text('UserId: $userId'),
                subtitle: Text('Position: $position'),
              );
            },
          );
        },
      ),
    );
  }
}
