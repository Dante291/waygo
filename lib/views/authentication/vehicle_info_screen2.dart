import 'dart:convert';
import 'dart:io';
import 'package:waygo/models/user.dart';
import 'package:waygo/view_models/authentication/registration_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class VehicleDetailsScreen extends StatefulWidget {
  final CustomUser user;

  const VehicleDetailsScreen({super.key, required this.user});

  @override
  VehicleDetailsScreenState createState() => VehicleDetailsScreenState();
}

class VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  final TextEditingController _vehicleNumberController =
      TextEditingController();
  final TextEditingController _vehicleAgeController = TextEditingController();

  File? _vehiclePhoto;
  File? _driverLicence;
  File? _userPhoto;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    if (await Permission.camera.isDenied) {
      await Permission.camera.request();
    }
    if (await Permission.photos.isDenied) {
      await Permission.photos.request();
    }
  }

  Future<void> _pickImage(String type) async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        switch (type) {
          case 'vehicle':
            _vehiclePhoto = File(pickedFile.path);
            break;
          case 'licence':
            _driverLicence = File(pickedFile.path);
            break;
          case 'user':
            _userPhoto = File(pickedFile.path);
            break;
        }
      });
    }
  }

  String _imageToBase64(File? image) {
    if (image == null) return '';
    return base64Encode(image.readAsBytesSync());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.yellow),
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
          child: Form(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.06),
                const Text(
                  'Fill in your vehicle details to complete the registration.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "Montserrat",
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                _buildTextField(_vehicleNumberController, 'Vehicle Number'),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                _buildUploadField('Upload Vehicle\'s Photo', 'vehicle'),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                _buildUploadField('Upload Driver\'s Licence', 'licence'),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                _buildUploadField('Upload Your Photo', 'user'),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                _buildTextField(_vehicleAgeController, 'Vehicle\'s Age',
                    inputType: TextInputType.number),
                SizedBox(height: MediaQuery.of(context).size.height * 0.09),
                ElevatedButton(
                  onPressed: () async {
                    widget.user.vehiclePhoto = _imageToBase64(_vehiclePhoto);
                    widget.user.driversLicensePhoto =
                        _imageToBase64(_driverLicence);
                    widget.user.userProfilePhoto = _imageToBase64(_userPhoto);
                    await saveUserData(widget.user, 'Offer Ride', context);
                    if (context.mounted) {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const NextScreen(),
                      ));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(215, 223, 127, 1),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      'Finish',
                      style: TextStyle(
                        fontFamily: "Montserrat",
                        fontSize: 18,
                        color: Color(0xFF0B2C36),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText,
      {TextInputType inputType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(
        fontFamily: "Montserrat",
        fontSize: 20,
        color: Colors.white,
      ),
      keyboardType: inputType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          fontFamily: "Montserrat",
          fontSize: 20,
          color: Color(0xFFD7DF7F),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $hintText';
        }
        return null;
      },
    );
  }

  Widget _buildUploadField(String labelText, String type) {
    return Row(
      children: [
        Expanded(
          child: Text(
            labelText,
            style: const TextStyle(
              fontFamily: "Montserrat",
              fontSize: 17,
              color: Color(0xFFD7DF7F),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.upload_file, color: Colors.yellow),
          onPressed: () => _pickImage(type),
        ),
      ],
    );
  }
}

class NextScreen extends StatelessWidget {
  const NextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
