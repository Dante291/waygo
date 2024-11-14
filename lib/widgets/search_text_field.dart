import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart'; // Use the correct import
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';

class AutocompleteSearchField extends StatefulWidget {
  bool showIconButton;
  final void Function(LatLng destination) onDestinationSelected;

  AutocompleteSearchField({
    super.key,
    this.showIconButton = false,
    required this.onDestinationSelected,
  });

  @override
  _AutocompleteSearchFieldState createState() =>
      _AutocompleteSearchFieldState();
}

class _AutocompleteSearchFieldState extends State<AutocompleteSearchField> {
  final TextEditingController _searchController = TextEditingController();
  LatLng? _currentLocation;
  String? _currentAddress;

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
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    _currentLocation = LatLng(position.latitude, position.longitude);
  }

  Future<void> _getCurrentAddress() async {
    final latlng =
        '${_currentLocation!.latitude},${_currentLocation!.longitude}';
    final url = Uri.parse('https://api.olamaps.io/places/v1/reverse-geocode')
        .replace(queryParameters: {
      'latlng': latlng,
      'api_key': 'W4ZIxk4chk1Y0C7tcHLcrzORBRrGS0WR6izkx25d',
    });

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _currentAddress = (data['results'] as List<dynamic>).first['name'];
      });
    }
  }

  Future<List<Map<String, dynamic>>> _getAutocompleteResults(
      String input) async {
    if (input.isEmpty) {
      return [];
    }

    final url = Uri.parse('https://api.olamaps.io/places/v1/autocomplete')
        .replace(queryParameters: {
      'input': input,
      'location':
          '${_currentLocation!.latitude},${_currentLocation!.longitude}',
      'api_key': 'W4ZIxk4chk1Y0C7tcHLcrzORBRrGS0WR6izkx25d',
    });

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(
          data['predictions'].map((result) => {
                'description': result['description'],
                'lat': result['geometry']['location']['lat'],
                'lng': result['geometry']['location']['lng'],
              }));
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(
              color: const Color.fromRGBO(215, 223, 127, 1), width: 2),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: TypeAheadField<Map<String, dynamic>>(
          builder: (context, controller, focusNode) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintStyle:
                    const TextStyle(color: Color.fromRGBO(215, 223, 127, 1)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(10.0),
                suffixIcon: widget.showIconButton
                    ? IconButton(
                        icon: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                        ),
                        onPressed: () async {
                          await _getCurrentAddress();
                          setState(() {
                            _searchController.clear();
                            _searchController.text = _currentAddress!;
                          });
                        },
                      )
                    : null,
              ),
              style: const TextStyle(color: Colors.white),
            );
          },
          hideOnEmpty: true,
          direction: VerticalDirection.up,
          suggestionsCallback: (pattern) async {
            final results = await _getAutocompleteResults(pattern);
            return results.take(4).toList();
          },
          itemBuilder: (context, suggestion) {
            return ListTile(
              title: Text(suggestion['description']),
            );
          },
          onSelected: (suggestion) {
            widget.onDestinationSelected(LatLng(
              suggestion['lat'],
              suggestion['lng'],
            ));
            _searchController.text = suggestion['description'];
          },
          hideOnSelect: true,
          controller: _searchController,
        ),
      ),
    );
  }
}
