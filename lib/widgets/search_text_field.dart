import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart'; // Use the correct import
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:waygo/view_models/find_ride_view_models/find_ride_view_model.dart';
import 'package:waygo/view_models/offer_ride_view_models/offer_ride_view_model.dart';

class AutocompleteSearchField extends ConsumerStatefulWidget {
  final bool showIconButton;
  final void Function(LatLng destination) onDestinationSelected;
  final bool Function()? validateStart;
  final bool isForOfferRide;
  final MapController mapController;
  final bool isOriginField;

  const AutocompleteSearchField({
    super.key,
    this.showIconButton = false,
    required this.onDestinationSelected,
    required this.mapController,
    this.validateStart,
    this.isForOfferRide = true,
    this.isOriginField = false,
  });

  @override
  _AutocompleteSearchFieldState createState() =>
      _AutocompleteSearchFieldState();
}

class _AutocompleteSearchFieldState
    extends ConsumerState<AutocompleteSearchField> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showError = false;
  LatLng? _currentLocation;
  String? _currentAddress;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && widget.validateStart != null) {
        // Validate "Start From" before letting the user type
        if (!(widget.validateStart!())) {
          setState(() {
            _showError = true;
          });
          _focusNode.unfocus();
        } else {
          setState(() {
            _showError = false;
          });
        }
      }
    });
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
    if (widget.isForOfferRide) {
      final offerRideViewModel = ref.watch(offerRideViewModelProvider);
      offerRideViewModel.setOrigin(
          _currentLocation!, widget.mapController, context);
    } else {
      final findRideViewModel = ref.watch(findRideViewModelProvider);
      await findRideViewModel.setOrigin(
          _currentLocation!, widget.mapController, context);
    }
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color.fromRGBO(215, 223, 127, 1),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: TypeAheadField<Map<String, dynamic>>(
              builder: (context, controller, focusNode) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintStyle: const TextStyle(
                        color: Color.fromRGBO(215, 223, 127, 1)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(10.0),
                    suffixIcon: widget.showIconButton
                        ? IconButton(
                            icon: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                            ),
                            onPressed: () async {
                              _focusNode.unfocus();
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
              controller: _searchController,
              focusNode: _focusNode,
              hideOnEmpty: true,
              direction: VerticalDirection.up,
              suggestionsCallback: (pattern) async {
                return await _getAutocompleteResults(pattern);
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(suggestion['description']),
                );
              },
              onSelected: (suggestion) async {
                _focusNode.unfocus();
                widget.onDestinationSelected(LatLng(
                  suggestion['lat'],
                  suggestion['lng'],
                ));
                _searchController.text = suggestion['description'];
                if (widget.isOriginField) {
                  if (widget.isForOfferRide) {
                    final offerRideViewModel =
                        ref.watch(offerRideViewModelProvider);
                    offerRideViewModel.setOrigin(
                        LatLng(
                          suggestion['lat'],
                          suggestion['lng'],
                        ),
                        widget.mapController,
                        context);
                  } else {
                    final findRideViewModel =
                        ref.watch(findRideViewModelProvider);
                    await findRideViewModel.setOrigin(
                        LatLng(
                          suggestion['lat'],
                          suggestion['lng'],
                        ),
                        widget.mapController,
                        context);
                  }
                }
              },
            ),
          ),
        ),
        if (_showError)
          const Padding(
            padding: EdgeInsets.only(left: 10, top: 2),
            child: Text(
              "Please fill 'Start From' first.",
              style: TextStyle(
                  color: Colors.red, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}
