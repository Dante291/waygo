import 'package:waygo/models/user.dart';
import 'package:waygo/views/authentication/user_details_screen.dart';
import 'package:flutter/material.dart';

class RideChoiceScreen extends StatefulWidget {
  @override
  _RideChoiceScreenState createState() => _RideChoiceScreenState();
}

class _RideChoiceScreenState extends State<RideChoiceScreen> {
  String _selectedOption = '';
  CustomUser User = CustomUser();

  void _selectOption(String option) {
    setState(() {
      _selectedOption = option;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B2C36),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
              ),
              const Text(
                'Are You Offering A Ride Or\nLooking For A Ride?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "Montserrat",
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.08,
              ),
              _buildRideOption(context, 'Offer Ride', 'assets/images/car.png',
                  () {
                _selectOption('Offer Ride');
                User.isDriver = true;
              }),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.08,
              ),
              _buildRideOption(context, 'Find Ride', 'assets/images/person.png',
                  () {
                _selectOption('Find Ride');
                User.isDriver = false;
              }),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  if (_selectedOption.isEmpty) {
                    // Show a message if no option is selected
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please select an option',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontFamily: "Montserrat",
                            color: Color.fromRGBO(255, 255, 255, 1),
                            fontSize: 16,
                          ),
                        ),
                        backgroundColor: Color.fromRGBO(255, 48, 48, 1),
                      ),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegistrationScreen(
                        user: User,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(215, 223, 127, 1),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 60, vertical: 10),
                  child: Text(
                    'Proceed',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontFamily: "Montserrat",
                      color: Color.fromRGBO(26, 81, 98, 1),
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.08,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRideOption(BuildContext context, String title, String imagePath,
      VoidCallback onTap) {
    bool isSelected = _selectedOption == title;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? const Color.fromRGBO(215, 223, 127, 1)
                : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Image.asset(
              imagePath,
              height: 100,
              width: 120,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontFamily: "Montserrat",
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
