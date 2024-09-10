import 'package:cloud_firestore/cloud_firestore.dart';

class Ride {
  String id;
  String driverId;
  List<String> passengerIds;
  GeoPoint startLocation;
  GeoPoint endLocation;
  String startAddress;
  String endAddress;
  DateTime departureTime;
  int availableSeats;
  double price;
  String status; // e.g., "scheduled", "in-progress", "completed", "cancelled"
  String vehicleType;
  List<String> stops;

  Ride({
    required this.id,
    required this.driverId,
    required this.passengerIds,
    required this.startLocation,
    required this.endLocation,
    required this.startAddress,
    required this.endAddress,
    required this.departureTime,
    required this.availableSeats,
    required this.price,
    required this.status,
    required this.vehicleType,
    this.stops = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'driverId': driverId,
      'passengerIds': passengerIds,
      'startLocation': startLocation,
      'endLocation': endLocation,
      'startAddress': startAddress,
      'endAddress': endAddress,
      'departureTime': departureTime,
      'availableSeats': availableSeats,
      'price': price,
      'status': status,
      'vehicleType': vehicleType,
      'stops': stops,
    };
  }
}
