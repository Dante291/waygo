import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:waygo/models/user.dart';

class UserProfileScreen extends StatelessWidget {
  final CustomUser user;

  const UserProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 20),
              _buildDetailsSection('Personal Details', [
                DetailItem(
                    icon: Icons.person, label: 'Full Name', value: user.name),
                DetailItem(
                    icon: Icons.email, label: 'Email', value: user.email),
                DetailItem(
                    icon: Icons.phone,
                    label: 'Contact No.',
                    value: user.phoneNumber),
                DetailItem(
                    icon: Icons.cake,
                    label: 'Date of Birth',
                    value: user.dateOfBirth),
              ]),
              const SizedBox(height: 20),
              if (user.isDriver)
                _buildDetailsSection('Vehicle Details', [
                  DetailItem(
                      icon: Icons.directions_car,
                      label: 'Vehicle Type',
                      value: user.vehicleType),
                  DetailItem(
                      icon: Icons.branding_watermark,
                      label: 'Vehicle Brand',
                      value: user.vehicleBrand),
                  DetailItem(
                      icon: Icons.model_training,
                      label: 'Vehicle Model',
                      value: user.vehicleModel),
                  DetailItem(
                      icon: Icons.pin,
                      label: 'Registration No.',
                      value: user.vehicleNumber),
                  DetailItem(
                      icon: Icons.card_membership,
                      label: "Driver's License",
                      value: user.driversLicensePhoto),
                ]),
              if (!user.isDriver)
                Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color.fromARGB(255, 0, 0, 0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12.withOpacity(0.05),
                            blurRadius: 4,
                            spreadRadius: 2,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 25),
                          Text('You have not registered any vehicle.'),
                          SizedBox(height: 25),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 24,
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: const Text(
                          'Vehcile Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D2E4E),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: user.userProfilePhoto.isNotEmpty
                    ? NetworkImage(user.userProfilePhoto)
                    : null,
                child: user.userProfilePhoto.isEmpty
                    ? Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '',
                        style: const TextStyle(fontSize: 40),
                      )
                    : null,
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            user.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            'Active Since: ${DateFormat('MMMM, yyyy').format(DateTime.now())}',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(String title, List<DetailItem> items) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color.fromARGB(255, 0, 0, 0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.05),
                    blurRadius: 4,
                    spreadRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
                  ...items.map((item) => _buildDetailItem(item)),
                  const SizedBox(height: 25),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 24,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D2E4E),
                  ),
                ),
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Edit Details'),
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: const Color.fromARGB(255, 0, 0, 0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(DetailItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Container(
        height: 40,
        color: const Color.fromARGB(181, 204, 204, 204),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
            ),
            Icon(
              item.icon,
              color: const Color(0xFF1D2E4E),
            ),
            const SizedBox(width: 16),
            Text(
              item.label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF576574),
              ),
            ),
            const Spacer(),
            Text(
              item.value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1D2E4E),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              width: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class DetailItem {
  final IconData icon;
  final String label;
  final String value;

  DetailItem({required this.icon, required this.label, required this.value});
}
