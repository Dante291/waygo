import 'package:flutter/material.dart';

class homeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hello, User Name!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose one of the options for your ride.',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Where are you headed?',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildOfferCard(
                      'First Ride',
                      '20% CASHBACK',
                      'Use Code "FIRST20"',
                    ),
                    const SizedBox(width: 16),
                    _buildOfferCard(
                      'First Ride',
                      '20% CAS',
                      'Use Code "FIRST"',
                    ),
                    const SizedBox(width: 16),
                    _buildOfferCard(
                      'Weekend Offer',
                      '15% OFF',
                      'Use Code "WEEKEND15"',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.green[200],
                      ),
                      child: const Text('Past Rides'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.teal,
                      ),
                      child: const Text('Upcoming'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: const [
                    RideListItem(
                      title: 'Shaheed Sthal (New Bus Adda), Ghaziabad',
                      date: 'June 27 - 5:14 PM',
                      price: '₹ 389',
                      status: 'Ride Completed',
                    ),
                    RideListItem(
                      title: 'Phase - I, Muradnagar, Aslat Nagar',
                      date: 'June 27 - 5:14 PM',
                      price: '₹ 389',
                      status: 'Ride Cancelled',
                    ),
                    RideListItem(
                      title: 'KIET Group of Inst., Meerut Road, Ghaziabad',
                      date: 'June 27 - 5:14 PM',
                      price: '₹ 389',
                      status: 'Ride Completed',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.local_offer), label: 'Offer Ride'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Find Ride'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }

  Widget _buildOfferCard(String title, String offer, String code) {
    return Container(
      width: 200, // Adjust the width as needed
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          Text(
            offer,
            style: const TextStyle(
                color: Colors.yellow,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          Text(
            code,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class RideListItem extends StatelessWidget {
  final String title;
  final String date;
  final String price;
  final String status;

  const RideListItem({
    Key? key,
    required this.title,
    required this.date,
    required this.price,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[300],
            child: Icon(Icons.person, color: Colors.grey[600]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  date,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: status == 'Ride Completed'
                        ? Colors.green[100]
                        : Colors.red[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      color: status == 'Ride Completed'
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
