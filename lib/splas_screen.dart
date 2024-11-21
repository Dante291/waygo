import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waygo/providers/user_provider.dart';
import 'package:waygo/views/after_auth/home.dart';
import 'package:waygo/views/authentication/phone_sign_up.dart';
import 'package:waygo/views/introduction/intro_pages.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateUser();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _navigateUser() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      bool isFirstTime = await _isFirstTime();
      if (!context.mounted) return;
      final userNotifier = ref.read(userProvider.notifier);
      await userNotifier.loadUserData(user.uid);
      if (isFirstTime) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => IntroPages()),
        );
      } else {
        final loadedUser = ref.read(userProvider);
        if (loadedUser != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => Home(user: loadedUser)),
          );
        } else {
          // Fallback to sign-up if user data couldn't be loaded
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const SignUpScreen()),
          );
        }
      }
    } else {
      // Fallback to sign-up if user data couldn't be loaded
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SignUpScreen()),
      );
    }
  }

  Future<bool> _isFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
    if (isFirstTime) {
      await prefs.setBool('isFirstTime', false);
    }
    return isFirstTime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(13, 47, 58, 1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/images/splash.png'),
            const Text(
              "Waygo",
              style: TextStyle(
                fontFamily: "Lalezar",
                fontSize: 48,
                fontWeight: FontWeight.w400,
                color: Color.fromRGBO(215, 223, 127, 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
