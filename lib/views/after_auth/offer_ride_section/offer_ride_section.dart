import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:waygo/widgets/search_text_field.dart';

class CurrentLocationMap extends StatefulWidget {
  @override
  _CurrentLocationMapState createState() => _CurrentLocationMapState();
}

class _CurrentLocationMapState extends State<CurrentLocationMap> {
  LatLng? _currentLocation;
  String? _currentAddress = 'Loading...';
  LatLng? _destinationLocation;
  LatLng? _origin;
  int selectedSeats = 3;
  double totalDistance = 0.0;
  String totalDuration = '';

  List<LatLng> _polylinePoints = [];

  final bool _isSearching = false;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Set a default location if permission is denied
        setState(() {
          _currentLocation =
              const LatLng(28.6139, 77.2090); // New Delhi coordinates
          _currentAddress = 'New Delhi, India';
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mapController.move(_adjustMapCenter(_currentLocation!), 10);
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _currentLocation = _currentLocation = const LatLng(28.6139, 77.2090);
        _currentAddress = 'New Delhi, India';
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(_adjustMapCenter(_currentLocation!), 10);
      });
      return;
    }

    // Get current position if permissions are granted
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(_adjustMapCenter(_currentLocation!), 16);
    });
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

  void _selectOrigin(LatLng origin) async {
    setState(() {
      _origin = origin;
    });
  }

  void _selectDestination(LatLng destination) async {
    setState(() {
      _destinationLocation = destination;
    });
    if (_currentLocation != null && _destinationLocation != null) {
      String origin =
          '${_currentLocation!.latitude},${_currentLocation!.longitude}';
      String destination =
          '${_destinationLocation!.latitude},${_destinationLocation!.longitude}';
      var directions = await getDirections(origin, destination);
      print(directions['routes']);
      if (directions['routes'] != null && directions['routes'].isNotEmpty) {
        String polyline = directions['routes'][0]['overview_polyline'];
        List<LatLng> decodedPoints = decodePolyline(polyline);
        List<dynamic> steps = directions['routes'][0]['legs'][0]['steps'];

        setState(() {
          _polylinePoints = decodedPoints;
          totalDistance = calculateTotalDistance(steps);
          totalDuration = calculateTotalDuration(steps);
        });
        _fitMapToPolyline();
      }
    }
  }

  String calculateTotalDuration(List<dynamic> steps) {
    int totalSeconds = 0;

    // Accumulate the duration for each step in seconds
    for (var step in steps) {
      totalSeconds += step['duration'] as int; // duration is in seconds
    }

    // Convert total seconds to hours and minutes
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;

    // Format output based on whether hours are greater than 0 or not
    if (hours > 0) {
      return '$hours hr ${minutes}m';
    } else {
      return '$minutes mins';
    }
  }

  double calculateTotalDistance(List<dynamic> steps) {
    double totalDistance = 0.0;

    for (var step in steps) {
      // Accumulate the distance for each step in meters
      totalDistance += step['distance'];
    }

    return totalDistance / 1000; // Convert meters to kilometers
  }

  void _fitMapToPolyline() {
    if (_polylinePoints.isEmpty) return;

    // Find the bounds for the polyline
    double minLat = _polylinePoints.first.latitude;
    double maxLat = _polylinePoints.first.latitude;
    double minLng = _polylinePoints.first.longitude;
    double maxLng = _polylinePoints.first.longitude;

    for (LatLng point in _polylinePoints) {
      minLat = point.latitude < minLat ? point.latitude : minLat;
      maxLat = point.latitude > maxLat ? point.latitude : maxLat;
      minLng = point.longitude < minLng ? point.longitude : minLng;
      maxLng = point.longitude > maxLng ? point.longitude : maxLng;
    }

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds(
          LatLng(minLat, minLng),
          LatLng(maxLat, maxLng),
        ),
        padding: EdgeInsets.only(
            top: 70, bottom: MediaQuery.of(context).size.height * 0.5 + 50),
      ),
    );
  }

  LatLng _adjustMapCenter(LatLng currentCenter) {
    double bottomSheetHeight = MediaQuery.of(context).size.height * 0.5;
    double totalHeight = MediaQuery.of(context).size.height;
    double visibleMapHeight = totalHeight - bottomSheetHeight;
    double offsetInPixels = visibleMapHeight;
    const double latDegreePerMeter = 0.0000089;
    double offsetInDegrees = offsetInPixels * latDegreePerMeter;
    return LatLng(
        currentCenter.latitude - offsetInDegrees, currentCenter.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          _currentLocation == null
              ? const Center(child: CircularProgressIndicator())
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentLocation!,
                    initialZoom: 16,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.waygo',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 80.0,
                          height: 80.0,
                          point: _currentLocation!,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 40.0,
                          ),
                        ),
                        if (_destinationLocation != null)
                          Marker(
                            width: 80.0,
                            height: 80.0,
                            point: _destinationLocation!,
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.blue,
                              size: 40.0,
                            ),
                          ),
                      ],
                    ),
                    if (_polylinePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _polylinePoints,
                            strokeWidth: 6.0,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                  ],
                ),
          if (_isSearching)
            const Center(
              child: CircularProgressIndicator(),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SingleChildScrollView(
              child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: DraggableScrollableSheet(
                    initialChildSize: 0.5,
                    minChildSize: 0.5,
                    maxChildSize: 0.5,
                    builder: (BuildContext context,
                        ScrollController scrollController) {
                      return Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: const BoxDecoration(
                          color: Color.fromRGBO(13, 47, 58, 1),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                width: 170,
                                height: 5,
                                decoration: const BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/images/pin-location.png',
                                  ),
                                  const Text(
                                    'Start from',
                                    style: TextStyle(
                                      color: Color.fromRGBO(215, 223, 127, 1),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AutocompleteSearchField(
                              showIconButton: true,
                              onDestinationSelected: (LatLng destination) {},
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/images/origin-icon.png',
                                  ),
                                  const Text(
                                    'Destination',
                                    style: TextStyle(
                                      color: Color.fromRGBO(215, 223, 127, 1),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AutocompleteSearchField(
                              onDestinationSelected: (LatLng destination) {
                                _selectDestination(destination);
                              },
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Distance: ${totalDistance.toStringAsFixed(1)}km',
                                  style: const TextStyle(
                                      color: Color.fromRGBO(215, 223, 127, 1),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'Time Estimated: $totalDuration',
                                  style: const TextStyle(
                                      color: Color.fromRGBO(215, 223, 127, 1),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                const Text(
                                  'Select No. Vacant Seats',
                                  style: TextStyle(
                                    color: Color.fromRGBO(215, 223, 127, 1),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: List.generate(4, (index) {
                                    return Container(
                                      width: 30,
                                      height: 30,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          backgroundColor:
                                              index == selectedSeats - 1
                                                  ? const Color.fromRGBO(
                                                      215, 223, 127, 1)
                                                  : Colors.transparent,
                                          side: const BorderSide(
                                              color: Color.fromRGBO(
                                                  215, 223, 127, 1)),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                        onPressed: () {},
                                        child: Text(
                                          (index + 1).toString(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: index == selectedSeats - 1
                                                ? Colors.black
                                                : const Color.fromRGBO(
                                                    215, 223, 127, 1),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    side: const BorderSide(
                                        color:
                                            Color.fromRGBO(215, 223, 127, 1)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {},
                                  child: const Row(
                                    children: [
                                      Icon(Icons.schedule,
                                          color:
                                              Color.fromRGBO(215, 223, 127, 1)),
                                      SizedBox(width: 5),
                                      Text(
                                        'Schedule Ride',
                                        style: TextStyle(
                                            color: Color.fromRGBO(
                                                215, 223, 127, 1)),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromRGBO(215, 223, 127, 1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {},
                                  child: const Row(
                                    children: [
                                      Icon(Icons.emoji_transportation,
                                          color: Colors.black),
                                      SizedBox(width: 5),
                                      Text('Offer Ride',
                                          style:
                                              TextStyle(color: Colors.black)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
