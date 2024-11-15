import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waygo/models/user.dart';

// Define UserNotifier to manage user state
class UserNotifier extends StateNotifier<CustomUser?> {
  UserNotifier() : super(null);

  // Fetch and set the user data
  Future<void> loadUserData(String uid) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        state = CustomUser.fromMap(doc.data()!); // Update user state
      } else {
        state = null; // No user data
      }
    } catch (e) {
      print("Error fetching user data: $e");
      state = null; // Handle error
    }
  }

  void updateUser(CustomUser user) {
    state = user;
  }

  // Clear user data (e.g., during logout)
  void clearUser() {
    state = null;
  }
}

// Define a global provider for the user
final userProvider =
    StateNotifierProvider<UserNotifier, CustomUser?>((ref) => UserNotifier());
