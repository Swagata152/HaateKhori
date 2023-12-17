import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

  Future<bool> doesUsernameExist(String username) async {
    try {
      QuerySnapshot querySnapshot = await usersCollection.where('username', isEqualTo: username).get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking username existence: $e');
      return false;
    }
  }

  Future<void> registerUser(String username, String name) async {
    try {
      await usersCollection.add({
        'username': username,
        'name': name,
      });
    } catch (e) {
      print('Error registering user: $e');
      // Handle error appropriately
    }
  }
}
