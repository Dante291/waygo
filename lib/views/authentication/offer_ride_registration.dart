import 'package:waygo/models/user.dart';
import 'package:waygo/views/authentication/vehicle_info_screen2.dart';
import 'package:flutter/material.dart';

class VehicleTypeScreen extends StatefulWidget {
  final CustomUser user;

  const VehicleTypeScreen({super.key, required this.user});

  @override
  _VehicleTypeScreenState createState() => _VehicleTypeScreenState();
}

class _VehicleTypeScreenState extends State<VehicleTypeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _vehicleBrandController = TextEditingController();
  final TextEditingController _vehicleModelController = TextEditingController();
  String? _selectedVehicleType;

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
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                const Text(
                  'Fill in your vehicle details to complete the registration.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "Montserrat",
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Choose your vehicle type',
                  style: TextStyle(
                    fontFamily: "Montserrat",
                    fontSize: 20,
                    color: Color(0xFFD7DF7F),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _vehicleTypeOption('Car', 'assets/images/car.png'),
                    _vehicleTypeOption('Scooter', 'assets/images/scooter.png'),
                    _vehicleTypeOption('Auto', 'assets/images/auto.png'),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.09),
                _buildTextField(_vehicleBrandController, 'Vehicle Brand'),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                _buildTextField(_vehicleModelController, 'Vehicle Model'),
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      widget.user.vehicleType = _selectedVehicleType!;
                      widget.user.vehicleBrand = _vehicleBrandController.text;
                      widget.user.vehicleModel = _vehicleModelController.text;
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              VehicleDetailsScreen(user: widget.user)));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD7DF7F),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 60, vertical: 10),
                    child: Text(
                      'Next',
                      style: TextStyle(
                        fontFamily: "Montserrat",
                        color: Color.fromRGBO(10, 35, 43, 1),
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
    );
  }

  Widget _vehicleTypeOption(String type, String imagePath) {
    final isSelected = _selectedVehicleType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedVehicleType = type;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color.fromRGBO(215, 223, 127, 1)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Image.asset(imagePath, height: 100, width: 100),
            Text(
              type,
              style: TextStyle(
                color: isSelected ? const Color(0xFFD7DF7F) : Colors.white,
              ),
            ),
          ],
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
