import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:latlong2/latlong.dart';
import 'package:waygo/models/ride_request.dart';
import 'package:waygo/providers/user_provider.dart';

class FindRideViewModel extends ChangeNotifier {
  LatLng? _currentLocation = const LatLng(28.6139, 77.2090);
  LatLng? _destinationLocation;
  LatLng? _origin;
  List<LatLng> _polylinePoints = [];

  double totalDistance = 0.0;
  String totalDuration = '0 mins.';
  bool isMapLoading = true;
  int selectedSeats = 1;
  int maxSeats = 4;

  LatLng? get currentLocation => _currentLocation;
  LatLng? get destinationLocation => _destinationLocation;
  LatLng? get origin => _origin;
  List<LatLng> get polylinePoints => _polylinePoints;

  void initialize() {
    _polylinePoints = [];
    totalDistance = 0.0;
    totalDuration = '0 mins.';
    _destinationLocation = null;
    _origin = null;
  }

  Future<void> checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    // Additional permission handling logic can be added here
  }

  LatLng _adjustMapCenter(LatLng currentCenter, BuildContext context) {
    double bottomSheetHeight = MediaQuery.of(context).size.height * 0.5;
    double totalHeight = MediaQuery.of(context).size.height;
    double visibleMapHeight = totalHeight - bottomSheetHeight;
    double offsetInPixels = visibleMapHeight;
    const double latDegreePerMeter = 0.0000089;
    double offsetInDegrees = offsetInPixels * latDegreePerMeter;
    return LatLng(
        currentCenter.latitude - offsetInDegrees, currentCenter.longitude);
  }

  Future<void> getCurrentLocation(
      MapController mapController, BuildContext context) async {
    isMapLoading = true;
    notifyListeners();

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      isMapLoading = false;
      notifyListeners();
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    _currentLocation = LatLng(position.latitude, position.longitude);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mapController.move(_adjustMapCenter(_currentLocation!, context), 16);
    });
    isMapLoading = false;
    notifyListeners();
  }

  Future<void> setOrigin(
      LatLng origin, MapController mapcontroller, BuildContext context) async {
    _origin = origin;
    _polylinePoints = [];
    totalDistance = 0.0;
    totalDuration = '0 mins.';
    if (_destinationLocation != null) {
      await selectDestination(_destinationLocation!);
      _fitMapToPolyline(_polylinePoints, mapcontroller, context);
    }
    notifyListeners();
  }

  void _fitMapToPolyline(List<LatLng> polylinePoints,
      MapController mapcontroller, BuildContext context) {
    if (polylinePoints.isEmpty) return;
    double minLat = polylinePoints.first.latitude;
    double maxLat = polylinePoints.first.latitude;
    double minLng = polylinePoints.first.longitude;
    double maxLng = polylinePoints.first.longitude;

    for (LatLng point in polylinePoints) {
      minLat = point.latitude < minLat ? point.latitude : minLat;
      maxLat = point.latitude > maxLat ? point.latitude : maxLat;
      minLng = point.longitude < minLng ? point.longitude : minLng;
      maxLng = point.longitude > maxLng ? point.longitude : maxLng;
    }

    mapcontroller.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds(
          LatLng(minLat, minLng),
          LatLng(maxLat, maxLng),
        ),
        padding: EdgeInsets.only(
          top: 70,
          bottom: MediaQuery.of(context).size.height * 0.5 + 50,
        ),
      ),
    );
  }

  Future<void> selectDestination(LatLng destination) async {
    _destinationLocation = destination;

    // Use origin location if set, otherwise use current location
    LatLng startPoint = _origin ?? _currentLocation!;

    if (_destinationLocation != null) {
      String origin = '${startPoint.latitude},${startPoint.longitude}';
      String destination =
          '${_destinationLocation!.latitude},${_destinationLocation!.longitude}';

      var directions = await getDirections(origin, destination);
      if (directions['routes'] != null && directions['routes'].isNotEmpty) {
        String polyline = directions['routes'][0]['overview_polyline'];
        List<LatLng> decodedPoints = decodePolyline(polyline);
        List<dynamic> steps = directions['routes'][0]['legs'][0]['steps'];
        _polylinePoints = decodedPoints;
        totalDistance = calculateTotalDistance(steps);
        totalDuration = calculateTotalDuration(steps);
        notifyListeners();
      }
    }
  }

  Future<Map<String, dynamic>> getDirections(
      String origin, String destination) async {
    const apiUrl = 'https://api.olamaps.io/routing/v1/directions';
    final response = await http.post(
      Uri.parse(
          '$apiUrl?origin=$origin&destination=$destination&mode=driving&alternatives=false&steps=true&overview=full&language=en&traffic_metadata=false&api_key=W4ZIxk4chk1Y0C7tcHLcrzORBRrGS0WR6izkx25d'),
      headers: {'accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch directions');
    }
  }

  List<LatLng> decodePolyline(String polyline) {
    List<LatLng> coordinates = [];
    int index = 0, len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      LatLng point = LatLng(lat / 1E5, lng / 1E5);
      coordinates.add(point);
    }

    return coordinates;
  }

  String calculateTotalDuration(List<dynamic> steps) {
    int totalSeconds = 0;

    for (var step in steps) {
      totalSeconds += step['duration'] as int;
    }

    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;

    if (hours > 0) {
      return '$hours hr ${minutes}m';
    } else {
      return '$minutes mins';
    }
  }

  double calculateTotalDistance(List<dynamic> steps) {
    double totalDistance = 0.0;

    for (var step in steps) {
      totalDistance += step['distance'];
    }

    return totalDistance / 1000;
  }

  void setSelectedSeats(int seats) {
    selectedSeats = seats;
    notifyListeners();
  }

  Future<void> createAndSaveRideRequest(WidgetRef ref) async {
    // Ensure both origin and destination are not null
    if (_origin == null || _destinationLocation == null) {
      throw Exception('Origin or destination is missing');
    }

    final customUser = ref.read(userProvider); // Get current user from provider
    if (customUser == null) {
      throw Exception('User information is missing');
    }

    if (selectedSeats < 1 || selectedSeats > maxSeats) {
      throw Exception('Invalid number of seats selected');
    }

    // Create the ride object
    final rideRequest = RideRequest(
      id: '', // Firestore will generate the ID
      userId: FirebaseAuth.instance.currentUser!.uid,
      rideId: '',
      requestedSeats: selectedSeats,
      pickupLocation: GeoPoint(_origin!.latitude, _origin!.longitude),
      dropoffLocation: GeoPoint(
          _destinationLocation!.latitude, _destinationLocation!.longitude),
      pickupAddress: await _getAddressForLocation(_origin!),
      dropoffAddress: await _getAddressForLocation(_destinationLocation!),
      requestTime: DateTime.now(),
      status: 'pending',
    );

    // Save the ride to Firestore
    await saveRideRequestToFirestore(rideRequest);
  }

  Future<DocumentReference> saveRideRequestToFirestore(
      RideRequest rideRequest) async {
    try {
      final rideRequestsCollection =
          FirebaseFirestore.instance.collection('ride_requests');
      final docRef = await rideRequestsCollection.add(rideRequest.toMap());

      // Update the ride request object with the generated ID
      rideRequest.id = docRef.id;

      return docRef;
    } catch (e) {
      print('Error saving ride request: $e');
      rethrow;
    }
  }

  Future<String> _getAddressForLocation(LatLng location) async {
    final latlng = '${location.latitude},${location.longitude}';
    final url = Uri.parse('https://api.olamaps.io/places/v1/reverse-geocode')
        .replace(queryParameters: {
      'latlng': latlng,
      'api_key': 'W4ZIxk4chk1Y0C7tcHLcrzORBRrGS0WR6izkx25d',
    });

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List<dynamic>).first['name'];
    }
    return 'Unknown Address';
  }
}

// Provider for the ViewModel
final findRideViewModelProvider =
    ChangeNotifierProvider((ref) => FindRideViewModel());
