import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:latlong2/latlong.dart';

class OfferRideViewModel extends ChangeNotifier {
  LatLng? _currentLocation = const LatLng(28.6139, 77.2090);
  LatLng? _destinationLocation;
  LatLng? _origin;
  List<LatLng> _polylinePoints = [];

  double totalDistance = 0.0;
  String totalDuration = '0 mins.';
  bool isMapLoading = true;
  String vehicleType = '';
  int selectedSeats = 1;
  int maxSeats = 1;

  LatLng? get currentLocation => _currentLocation;
  LatLng? get destinationLocation => _destinationLocation;
  LatLng? get origin => _origin;
  List<LatLng> get polylinePoints => _polylinePoints;

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

  void initialize() {
    _polylinePoints = [];
    totalDistance = 0.0;
    totalDuration = '0 mins.';
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

  void setOrigin(LatLng origin) {
    _origin = origin;
    _polylinePoints = [];
    totalDistance = 0.0;
    totalDuration = '0 mins.';
    notifyListeners();
  }

  void initializeVehicleSettings(String newVehicleType) {
    vehicleType = newVehicleType;

    if (vehicleType == 'Car') {
      maxSeats = 4;
      selectedSeats = 4;
    } else if (vehicleType == 'Scooter') {
      maxSeats = 1;
      selectedSeats = 1;
    } else {
      maxSeats = 3;
      selectedSeats = 3;
    }
    notifyListeners();
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
        print(11);

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

    return totalDistance / 1000; // Convert meters to kilometers
  }

  void setSelectedSeats(int seats) {
    selectedSeats = seats;
    notifyListeners();
  }
}

// Provider for the ViewModel
final offerRideViewModelProvider =
    ChangeNotifierProvider((ref) => OfferRideViewModel());
