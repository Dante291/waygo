import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:waygo/models/user.dart'; // Import your CustomUser model

Future<void> saveUserData(
    CustomUser customUser, String userType, BuildContext context) async {
  try {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return;
    }

    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    // Update the isDriver field based on userType
    customUser.isDriver = userType == 'Offer Ride';

    // Save the CustomUser data in a single document
    await userRef.set(customUser.toMap(), SetOptions(merge: true));
  } catch (e) {
    if (context.mounted) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0B2C36),
              title: const Text(
                'Error',
                style: TextStyle(color: Color(0xFFD7DF7F)),
              ),
              content: const Text(
                'Cannot register right now. Please try again later.',
                style: TextStyle(color: Colors.white),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Color(0xFFD7DF7F)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }
  }
}
