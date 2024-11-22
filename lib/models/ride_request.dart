import 'package:cloud_firestore/cloud_firestore.dart';

class RideRequest {
  String id;
  String userId;
  String? rideId;
  GeoPoint pickupLocation;
  GeoPoint dropoffLocation;
  int requestedSeats;
  String pickupAddress;
  String dropoffAddress;
  DateTime requestTime;
  String
      status; // e.g., "pending", "matched", "accepted", "rejected", "completed"

  RideRequest({
    required this.id,
    required this.userId,
    this.rideId,
    required this.pickupLocation,
    required this.requestedSeats,
    required this.dropoffLocation,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.requestTime,
    required this.status,
  });

  // Convert to Firestore-friendly map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'rideId': rideId,
      'requestedSeats': requestedSeats,
      'pickupLocation': pickupLocation,
      'dropoffLocation': dropoffLocation,
      'pickupAddress': pickupAddress,
      'dropoffAddress': dropoffAddress,
      'requestTime': requestTime,
      'status': status,
    };
  }

  // Factory constructor to create from Firestore document
  factory RideRequest.fromMap(Map<String, dynamic> map) {
    return RideRequest(
      id: map['id'],
      userId: map['userId'],
      rideId: map['rideId'],
      requestedSeats: map['requestedSeats'],
      pickupLocation: map['pickupLocation'],
      dropoffLocation: map['dropoffLocation'],
      pickupAddress: map['pickupAddress'],
      dropoffAddress: map['dropoffAddress'],
      requestTime: (map['requestTime'] as Timestamp).toDate(),
      status: map['status'],
    );
  }
}
