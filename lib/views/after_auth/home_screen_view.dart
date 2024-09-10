import 'package:flutter/material.dart';
import 'package:waygo/models/user.dart';
import 'package:waygo/widgets/ride_list_item.dart';

class HomeScreen extends StatefulWidget {
  final CustomUser user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.03),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${widget.user.name.toUpperCase()}!',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Choose one of the options for your ride.',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const Spacer(),
              CircleAvatar(
                radius: 35,
                backgroundImage: widget.user.userProfilePhoto.isNotEmpty
                    ? NetworkImage(widget.user.userProfilePhoto)
                    : null,
                backgroundColor: Colors.blueGrey,
                child: widget.user.userProfilePhoto.isEmpty
                    ? Text(
                        _getInitials(widget.user.name),
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
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(10, 35, 43, 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Where are you headed?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Image.asset(
                    "assets/images/navigator.png",
                    width: 30,
                    height: 30,
                  )
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: SizedBox(
            height: 130,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildOfferCard('First Ride', '20% CASHBACK',
                    'Use Code "FIRST20"', context),
                const SizedBox(width: 16),
                _buildOfferCard(
                    'First Ride', '20% CAS', 'Use Code "FIRST"', context),
                const SizedBox(width: 16),
                _buildOfferCard('Weekend Offer', '15% OFF',
                    'Use Code "WEEKEND15"', context),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _tabButton(
                  _selectedTab == 0,
                  'Past Rides',
                  () => setState(() {
                    _selectedTab = 0;
                  }),
                  true,
                ),
                _tabButton(
                  _selectedTab == 1,
                  'Upcoming Rides',
                  () => setState(() {
                    _selectedTab = 1;
                  }),
                  false,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 8.0),
            child: Scrollbar(
              thumbVisibility: true,
              thickness: 6.0,
              radius: const Radius.circular(10),
              child: Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: ListView(
                  children: const [
                    RideListItem(
                      title: 'Shaheed Sthal (New Bus Adda), Ghaziabad',
                      date: 'June 27 - 5:14 PM',
                      price: '₹ 389',
                      status: 'Ride Completed',
                      image: 'assets/images/car.png',
                    ),
                    RideListItem(
                      title: 'Phase - I, Muradnagar, Aslat Nagar',
                      date: 'June 27 - 5:14 PM',
                      price: '₹ 389',
                      status: 'Ride Cancelled',
                      image: 'assets/images/auto.png',
                    ),
                    RideListItem(
                      title: 'KIET Group of Inst., Meerut Road, Ghaziabad',
                      date: 'June 27 - 5:14 PM',
                      price: '₹ 389',
                      status: 'Ride Completed',
                      image: 'assets/images/scooter.png',
                    ),
                    RideListItem(
                      title: 'KIET Group of Inst., Meerut Road, Ghaziabad',
                      date: 'June 27 - 5:14 PM',
                      price: '₹ 389',
                      status: 'Ride Completed',
                      image: 'assets/images/scooter.png',
                    ),
                    RideListItem(
                      title: 'KIET Group of Inst., Meerut Road, Ghaziabad',
                      date: 'June 27 - 5:14 PM',
                      price: '₹ 389',
                      status: 'Ride Completed',
                      image: 'assets/images/scooter.png',
                    ),
                    RideListItem(
                      title: 'KIET Group of Inst., Meerut Road, Ghaziabad',
                      date: 'June 27 - 5:14 PM',
                      price: '₹ 389',
                      status: 'Ride Completed',
                      image: 'assets/images/scooter.png',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Widget _tabButton(
    bool isSelected, String text, VoidCallback onTap, bool isLeft) {
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromRGBO(215, 223, 127, 1)
              : const Color.fromRGBO(26, 81, 98, 1),
          borderRadius: isSelected
              ? BorderRadius.circular(8)
              : isLeft
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    )
                  : const BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
          border:
              isSelected ? Border.all(color: Colors.yellow, width: 1.5) : null,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected
                  ? const Color.fromRGBO(26, 81, 98, 1)
                  : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _buildOfferCard(
    String title, String offer, String code, BuildContext context) {
  return Container(
    width: MediaQuery.of(context).size.width * 0.58,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [
          Color.fromRGBO(26, 81, 98, 1),
          Color.fromRGBO(0, 0, 0, 1),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 22),
        ),
        Text(
          offer,
          style: const TextStyle(
              color: Colors.yellow, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          code,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
      ],
    ),
  );
}
