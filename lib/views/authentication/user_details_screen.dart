import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waygo/models/user.dart';
import 'package:waygo/views/authentication/emergency_details.dart';
import 'package:waygo/views/authentication/offer_ride_registration.dart';

class RegistrationScreen extends StatefulWidget {
  final CustomUser user;

  const RegistrationScreen({super.key, required this.user});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  bool _otpOnEmail = false;
  String _gender = 'Male';
  final _formKey = GlobalKey<FormState>();

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    }
    const emailPattern = r'^[^@]+@[^@]+\.[^@]+';
    if (!RegExp(emailPattern).hasMatch(value)) {
      return 'Please enter a valid email address';
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

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your Name';
    }
    return null;
  }

  String? _validateDOB(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your date of birth';
    }

    final datePattern = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!datePattern.hasMatch(value)) {
      return 'Please enter a valid date (dd/mm/yyyy)';
    }

    final parts = value.split('/');
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) {
      return 'Invalid date format';
    }

    final dob = DateTime(year, month, day);
    if (dob.year != year || dob.month != month || dob.day != day) {
      return 'Please enter a valid date';
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
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  const Text(
                    'Fill the details required to register\non WayGo',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: "Montserrat",
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  _buildTextField(_nameController, 'Name',
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
                              controller: _phoneController,
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
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  _buildTextField(_emailController, 'Email address',
                      validator: _validateEmail),
                  Row(
                    children: [
                      Checkbox(
                        value: _otpOnEmail,
                        onChanged: (bool? value) {
                          setState(() {
                            _otpOnEmail = value ?? false;
                          });
                        },
                        activeColor: const Color.fromRGBO(215, 223, 127, 1),
                        checkColor: Colors.black,
                      ),
                      const Text(
                        'Receive the verification OTP on email.',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                  _buildTextField(_dobController, 'Date Of Birth (dd/mm/yyyy)',
                      validator: _validateDOB),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  _buildGenderSelection(),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.user.name = _nameController.text;
                        widget.user.phoneNumber = _phoneController.text;
                        widget.user.email = _emailController.text;
                        widget.user.dateOfBirth = _dobController.text;
                        widget.user.gender = _gender;
                        widget.user.otpOnEmail = _otpOnEmail;

                        if (widget.user.isDriver) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VehicleTypeScreen(
                                user: widget.user,
                              ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EmergencyContactScreen(
                                user: widget.user,
                              ),
                            ),
                          );
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
            fontFamily: "Montserrat",
          ),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildGenderSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Expanded(
            child: Text(
              "Gender",
              style: TextStyle(
                color: Color.fromRGBO(215, 223, 127, 1),
                fontFamily: "Montserrat",
              ),
            ),
          ),
          _buildGenderOption('Male'),
          _buildGenderOption('Female'),
          _buildGenderOption('Others'),
        ],
      ),
    );
  }

  Widget _buildGenderOption(String gender) {
    return Row(
      children: [
        Radio<String>(
          value: gender,
          groupValue: _gender,
          onChanged: (value) {
            setState(() {
              _gender = value!;
            });
          },
          activeColor: const Color.fromRGBO(215, 223, 127, 1),
        ),
        Text(
          gender,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
