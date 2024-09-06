import 'package:waygo/models/user.dart';
import 'package:waygo/view_models/authentication/registration_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waygo/views/after_auth/home_view_screen.dart';

class EmergencyContactScreen extends StatefulWidget {
  final CustomUser user;

  const EmergencyContactScreen({super.key, required this.user});

  @override
  _EmergencyContactScreenState createState() => _EmergencyContactScreenState();
}

class _EmergencyContactScreenState extends State<EmergencyContactScreen> {
  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _contactPhoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your Name';
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }

    if (value.length < 10) {
      return 'Please enter a valid phone number';
    }
    return null;
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
      ),
      backgroundColor: const Color(0xFF0B2C36),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.09),
                  const Text(
                    'Emergency Contact Details',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: "Montserrat",
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  _buildTextField(_contactNameController, 'Contact Name',
                      validator: _validateName),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(10, 35, 43, 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          '+91',
                          style: TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: 17,
                            color: Color.fromRGBO(215, 223, 127, 1),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Text(
                            '|',
                            style: TextStyle(
                              fontFamily: "Montserrat",
                              fontSize: 24,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: TextFormField(
                              validator: _validatePhoneNumber,
                              controller: _contactPhoneController,
                              maxLines: 1,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(10),
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              style: const TextStyle(
                                fontFamily: "Montserrat",
                                fontSize: 17,
                                color: Colors.white,
                              ),
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Enter your phone number',
                                hintStyle: TextStyle(
                                  fontFamily: "Montserrat",
                                  fontSize: 16,
                                  color: Color.fromRGBO(215, 223, 127, 1),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Image.asset('assets/images/emergency.png', height: 200),
                  const Text(
                    textAlign: TextAlign.center,
                    "Your emergency contact will be notified with\n an SOS message containing your live location in case of emergency",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontFamily: "Montserrat",
                      color: Color.fromRGBO(215, 223, 127, 1),
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.06),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.user.emergencyContactName =
                            _contactNameController.text;
                        widget.user.emergencyContactName =
                            _contactPhoneController.text;

                        if (widget.user.isDriver == false) {
                          saveUserData(widget.user, 'Find Ride', context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => homeScreen(),
                            ),
                          );
                          // Navigator.of(context)
                          //     .pop();
                        } else {
                          // Navigate to vehicle details screen
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => VehicleDetailsScreen(
                          //       userData: completeUserData,
                          //     ),
                          //   ),
                          // );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(215, 223, 127, 1),
                    ),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Text(
                        'Next',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontFamily: "Montserrat",
                          color: Color.fromRGBO(26, 81, 98, 1),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText,
      {String? Function(String?)? validator}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(10, 35, 43, 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
              color: Color.fromRGBO(215, 223, 127, 1),
              fontFamily: "Montserrat"),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}
