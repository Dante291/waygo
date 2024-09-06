import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:waygo/views/authentication/otp_success_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  OtpVerificationScreen({
    Key? key,
    required this.verificationId,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;
  int? _previousIndex;
  bool _isResendAvailable = false;
  late Timer _timer;
  int _start = 120; // 2 minutes in seconds

  @override
  void initState() {
    super.initState();
    _verificationId = widget.verificationId;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _isResendAvailable = true;
        });
        _timer.cancel();
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _verifyOtp() async {
    final otp = _controllers.map((controller) => controller.text.trim()).join();
    if (otp.length != 6) {
      return;
    }

    final PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: otp,
    );

    try {
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      print("Successfully signed in with UID: ${userCredential.user?.uid}");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SuccessScreen()),
      );
    } catch (e) {
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
              'Wrong OTP. Please try again.',
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
        },
      );
    }
  }

  void _resendOtp() async {
    if (!_isResendAvailable) return;

    await _auth.verifyPhoneNumber(
      phoneNumber: '+91${widget.phoneNumber}',
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        print('Verification failed: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _start = 120;
          _isResendAvailable = false;
        });
        _startTimer();
        print('OTP resent successfully.');
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD7DF7F)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: const Color(0xFF0B2C36),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.15,
            ),
            const Text(
              'Enter the OTP received on your\nmobile number',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: "Montserrat",
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.04,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) => _buildOtpBox(index)),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.04,
            ),
            _isResendAvailable
                ? RichText(
                    text: TextSpan(
                      text: "Didn't receive the OTP? Click ",
                      style: const TextStyle(
                        fontFamily: "Montserrat",
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      children: [
                        TextSpan(
                          text: "here",
                          style: const TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: 14,
                            color: Color.fromRGBO(215, 223, 127, 1),
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = _resendOtp,
                        ),
                        const TextSpan(
                          text: " to resend.",
                        ),
                      ],
                    ),
                  )
                : Text(
                    'Resend OTP in ${_formatTime(_start)}',
                    style: const TextStyle(
                      fontFamily: "Montserrat",
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
            const Spacer(),
            ElevatedButton(
              onPressed: _verifyOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(215, 223, 127, 1),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 60),
                child: Text(
                  'Next',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Montserrat",
                    color: Color.fromRGBO(26, 81, 98, 1),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
      backgroundColor: const Color(0xFF0B2C36),
    );
  }

  Widget _buildOtpBox(int index) {
    return Container(
      width: 50,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextField(
        focusNode: _focusNodes[index],
        controller: _controllers[index],
        maxLength: 1,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: "Montserrat",
          fontSize: 24,
          color: Colors.white,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
        ),
        onChanged: (value) {
          if (_previousIndex != null &&
              _previousIndex == index &&
              value.isNotEmpty) {
            FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
            _previousIndex = null;
            return;
          }

          if (value.length == 1) {
            if (index < _focusNodes.length - 1) {
              FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
            } else {
              _focusNodes[index].unfocus();
            }
          } else if (value.isEmpty) {
            if (index > 0) {
              FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
              _previousIndex = index - 1;
            }
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    _timer.cancel();
    super.dispose();
  }
}
