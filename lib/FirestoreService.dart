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

  Future<bool> isPasswordCorrect(String username, String password) async {
    try {
      QuerySnapshot querySnapshot = await usersCollection.where('username', isEqualTo: username).get();

      if (querySnapshot.docs.isNotEmpty) {
        // Assuming there is only one user with a unique username
        String storedPassword = querySnapshot.docs.first['password'];
        return storedPassword == password;
      } else {
        // Username not found
        return false;
      }
    } catch (e) {
      print('Error checking password: $e');
      return false;
    }
  }

  Future<void> registerUser(String username, String name, String password) async {
    try {
      await usersCollection.add({
        'username': username,
        'name': name,
        'password': password,
      });
    } catch (e) {
      print('Error registering user: $e');
      // Handle error appropriately
    }
  }
}
