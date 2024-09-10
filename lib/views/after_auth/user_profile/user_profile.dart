import 'package:flutter/material.dart';
import 'package:waygo/models/user.dart';

class UserProfile extends StatelessWidget {
  final CustomUser user;

  const UserProfile({super.key, required this.user});
  String _getInitials(String name) {
    List<String> nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return nameParts[0][0].toUpperCase() + nameParts[1][0].toUpperCase();
    } else if (nameParts.isNotEmpty) {
      return nameParts[0][0].toUpperCase();
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            _buildAppBar(),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            const Center(
              child: Text(
                "Account Summary",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            _buildAccountSummary(),
            const Divider(
              color: Color.fromARGB(255, 196, 196, 196),
              thickness: 3.5,
            ),
            _buildMenuItems(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color.fromRGBO(26, 81, 98, 1),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, User Name!',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.yellow, size: 16),
                    Icon(Icons.star, color: Colors.yellow, size: 16),
                    Icon(Icons.star, color: Colors.yellow, size: 16),
                    Icon(Icons.star, color: Colors.yellow, size: 16),
                    Icon(Icons.star_half, color: Colors.yellow, size: 16),
                    SizedBox(width: 4),
                    Text('4.1 (Excellent)',
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
                Text('(112 Reviews)', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          CircleAvatar(
            radius: 35,
            backgroundImage: user.userProfilePhoto.isNotEmpty
                ? NetworkImage(user.userProfilePhoto)
                : null,
            backgroundColor: Colors.blueGrey,
            child: user.userProfilePhoto.isEmpty
                ? Text(
                    _getInitials(user.name),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSummary() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: _buildSummaryCard(
                      'Today\'s Earnings', '₹987.18', 'rupee_icon.png')),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildSummaryCard(
                      'Distance Traveled', '60 KM', 'road_icon.png')),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _buildSummaryCard('Rides Today', '7', 'car_icon.png')),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildSummaryCard(
                      'Upcoming Rides', '2', 'upcoming_rides.png')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, String image) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(10, 34, 41, 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset('assets/images/$image'),
          Expanded(
            child: Column(
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Color.fromRGBO(215, 223, 127, 1), fontSize: 12)),
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems() {
    final menuItems = [
      {'icon': Icons.list, 'title': 'All rides detail'},
      {'icon': Icons.settings, 'title': 'Settings'},
      {'icon': Icons.help, 'title': 'Help'},
      {'icon': Icons.description, 'title': 'Legal'},
      {'icon': Icons.person, 'title': 'Account Settings'},
      {'icon': Icons.card_giftcard, 'title': 'Refer & Earn'},
      {'icon': Icons.exit_to_app, 'title': 'Log Out'},
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListView.builder(
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return ListTile(
            leading: Icon(item['icon'] as IconData),
            title: Text(item['title'] as String),
            onTap: () {},
          );
        },
      ),
    );
  }
}
