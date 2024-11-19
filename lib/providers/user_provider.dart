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
        final userData = doc.data()!;
        userData['id'] = doc.id;
        state = CustomUser.fromMap(userData);
      } else {
        state = null;
      }
    } catch (e) {
      print("Error fetching user data: $e");
      state = null;
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
