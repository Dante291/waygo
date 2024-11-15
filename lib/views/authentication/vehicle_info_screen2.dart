import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waygo/models/user.dart';
import 'package:waygo/view_models/authentication/registration_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:waygo/views/after_auth/home.dart';

class VehicleDetailsScreen extends ConsumerStatefulWidget {
  final CustomUser user;

  const VehicleDetailsScreen({super.key, required this.user});

  @override
  VehicleDetailsScreenState createState() => VehicleDetailsScreenState();
}

class VehicleDetailsScreenState extends ConsumerState<VehicleDetailsScreen> {
  final TextEditingController _vehicleNumberController =
      TextEditingController();
  final TextEditingController _vehicleAgeController = TextEditingController();

  File? _vehiclePhoto;
  File? _driverLicence;
  File? _userPhoto;

  String? _vehiclePhotoName;
  String? _driverLicenceName;
  String? _userPhotoName;

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
            _vehiclePhotoName = pickedFile.name;
            break;
          case 'licence':
            _driverLicence = File(pickedFile.path);
            _driverLicenceName = pickedFile.name;
            break;
          case 'user':
            _userPhoto = File(pickedFile.path);
            _userPhotoName = pickedFile.name;
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
                    await saveUserData(widget.user, 'Offer Ride', ref, context);
                    if (context.mounted) {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => Home(
                          user: widget.user,
                        ),
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
    String? fileName; // Local variable for file name

    switch (type) {
      case 'vehicle':
        fileName = _vehiclePhotoName;
        break;
      case 'licence':
        fileName = _driverLicenceName;
        break;
      case 'user':
        fileName = _userPhotoName;
        break;
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                labelText,
                style: const TextStyle(
                  fontFamily: "Montserrat",
                  fontSize: 17,
                  color: Color(0xFFD7DF7F),
                ),
              ),
              if (fileName != null)
                Row(
                  children: [
                    Text(
                      fileName,
                      style: const TextStyle(
                        fontFamily: "Montserrat",
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          // Clear the image and file name based on type
                          switch (type) {
                            case 'vehicle':
                              _vehiclePhoto = null;
                              _vehiclePhotoName = null;
                              break;
                            case 'licence':
                              _driverLicence = null;
                              _driverLicenceName = null;
                              break;
                            case 'user':
                              _userPhoto = null;
                              _userPhotoName = null;
                              break;
                          }
                        });
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.upload_file,
              color: (fileName == null) ? Colors.yellow : Colors.grey),
          onPressed: (fileName == null) ? () => _pickImage(type) : null,
        ),
      ],
    );
  }
}
