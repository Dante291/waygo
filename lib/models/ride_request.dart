import 'package:cloud_firestore/cloud_firestore.dart';

class RideRequest {
  String id;
  String userId;
  String rideId;
  GeoPoint pickupLocation;
  String pickupAddress;
  DateTime requestTime;
  String status; // e.g., "pending", "accepted", "rejected"

  RideRequest({
    required this.id,
    required this.userId,
    required this.rideId,
    required this.pickupLocation,
    required this.pickupAddress,
    required this.requestTime,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'rideId': rideId,
      'pickupLocation': pickupLocation,
      'pickupAddress': pickupAddress,
      'requestTime': requestTime,
      'status': status,
    };
  }
}
