import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:waygo/providers/user_provider.dart';
import 'package:waygo/view_models/offer_ride_view_models/offer_ride_view_model.dart';

import 'package:waygo/widgets/search_text_field.dart';

class CurrentLocationMap extends ConsumerStatefulWidget {
  @override
  _CurrentLocationMapState createState() => _CurrentLocationMapState();
}

class _CurrentLocationMapState extends ConsumerState<CurrentLocationMap> {
  final MapController _mapController = MapController();
  bool _mounted = true;

  bool _showInfoCard = false;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  OverlayEntry? _overlayEntry;

  final GlobalKey _infoCardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mounted) {
        final viewModel = ref.read(offerRideViewModelProvider);
        viewModel.initialize();
        viewModel.checkPermissions();
        viewModel.getCurrentLocation(_mapController, context);
        final customUser = ref.read(userProvider);
        if (customUser != null) {
          viewModel.initializeVehicleSettings(customUser.vehicleType);
        }
      }
    });
  }

  @override
  void dispose() {
    _mounted = false;
    _removeOverlay();
    super.dispose();
  }

  void _showInfoOverlay(BuildContext context) {
    _removeOverlay();

    // Get the position of the info card block
    RenderBox renderBox =
        _infoCardKey.currentContext!.findRenderObject() as RenderBox;
    Offset position = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: position.dy - 130,
        left: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            height: 130,
            width: 300,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(10, 34, 41, 1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    Color.fromRGBO(215, 223, 127, 1), // Dark gray border color
                width: 3,
              ),
            ),
            child: const Text(
              textAlign: TextAlign.center,
              'Fare is generated dynamically. However,\nyou can adjust fare up to\n +/- ₹100.',
              style: TextStyle(
                color: Color.fromRGBO(215, 223, 127, 1),
                fontSize: 18,
                height: 1.3,
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    Future.delayed(const Duration(seconds: 5), _removeOverlay);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color.fromRGBO(215, 223, 127, 1),
              surface: Color.fromRGBO(13, 47, 58, 1),
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Color.fromRGBO(215, 223, 127, 1),
                surface: Color.fromRGBO(13, 47, 58, 1),
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          _selectedTime = time;
        });
      }
    }
  }

  void _fitMapToPolyline(List<LatLng> polylinePoints) {
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

    _mapController.fitCamera(
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

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(offerRideViewModelProvider);
    final customUser = ref.watch(userProvider);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          viewModel.currentLocation == null
              ? const Center(child: CircularProgressIndicator())
              : viewModel.isMapLoading == true
                  ? const Align(
                      alignment: Alignment(0.0, -0.5),
                      child: CircularProgressIndicator(),
                    )
                  : FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: viewModel.currentLocation!,
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
                              point: viewModel.currentLocation!,
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 40.0,
                              ),
                            ),
                            if (viewModel.destinationLocation != null)
                              Marker(
                                width: 80.0,
                                height: 80.0,
                                point: viewModel.destinationLocation!,
                                child: const Icon(
                                  Icons.location_pin,
                                  color: Colors.blue,
                                  size: 40.0,
                                ),
                              ),
                          ],
                        ),
                        if (viewModel.polylinePoints.isNotEmpty)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: viewModel.polylinePoints,
                                strokeWidth: 6.0,
                                color: Colors.blue,
                              ),
                            ],
                          ),
                      ],
                    ),
          Positioned(
            bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 35 : 0,
            left: 0,
            right: 0,
            child: SingleChildScrollView(
              child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.535,
                  child: DraggableScrollableSheet(
                    initialChildSize: 0.99,
                    minChildSize: 0.52,
                    maxChildSize: 1,
                    snap: true,
                    snapSizes: const [0.52, 0.99],
                    builder: (BuildContext context,
                        ScrollController scrollController) {
                      return Container(
                        padding:
                            const EdgeInsets.only(left: 16, right: 16, top: 16),
                        decoration: const BoxDecoration(
                          color: Color.fromRGBO(13, 47, 58, 1),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: ListView(
                          controller: scrollController,
                          shrinkWrap: true,
                          physics: const AlwaysScrollableScrollPhysics(),
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
                                  Image.asset('assets/images/pin-location.png'),
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
                              onDestinationSelected: (LatLng origin) {
                                viewModel.setOrigin(origin);
                              },
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Row(
                                children: [
                                  Image.asset('assets/images/origin-icon.png'),
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
                              onDestinationSelected:
                                  (LatLng destination) async {
                                await viewModel.selectDestination(destination);
                                _fitMapToPolyline(viewModel.polylinePoints);
                              },
                              validateStart: () => viewModel.origin != null,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        const TextSpan(
                                          text: 'Distance: ',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                              '${viewModel.totalDistance.toStringAsFixed(1)} Kms',
                                          style: const TextStyle(
                                            color: Color.fromRGBO(
                                                215, 223, 127, 1),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        const TextSpan(
                                          text: 'Time Estimated: ',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                        TextSpan(
                                          text: viewModel.totalDuration,
                                          style: const TextStyle(
                                            color: Color.fromRGBO(
                                                215, 223, 127, 1),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Left side: Fare label with info icon
                                Padding(
                                  padding: const EdgeInsets.only(left: 16),
                                  child: Row(
                                    children: [
                                      const Text(
                                        'Fare',
                                        style: TextStyle(
                                          color:
                                              Color.fromRGBO(215, 223, 127, 1),
                                          fontSize: 17,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      GestureDetector(
                                        onTap: () => _showInfoOverlay(context),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: const Color.fromRGBO(
                                                10, 34, 41, 1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            key: _infoCardKey,
                                            children: [
                                              Image.asset(
                                                  'assets/images/info.png'),
                                              const SizedBox(width: 6),
                                              const Text(
                                                'Click for\n more info',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      215, 223, 127, 1),
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Right side: Decrement, Fare value, Increment
                                Row(
                                  children: [
                                    GestureDetector(
                                      child: Image.asset(
                                          'assets/images/minus.png'),
                                      onTap: () {
                                        double currentFare = viewModel.fare;
                                        if (currentFare > 0) {
                                          setState(() {
                                            viewModel.fare = (currentFare - 10);
                                          });
                                        }
                                      },
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        width: 80,
                                        height: 40,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: const Color.fromRGBO(
                                              10, 34, 41, 1),
                                        ),
                                        child: RichText(
                                          text: TextSpan(
                                            children: [
                                              const TextSpan(
                                                text: '₹ ',
                                                style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      215, 223, 127, 1),
                                                  fontSize: 14,
                                                ),
                                              ),
                                              TextSpan(
                                                text: viewModel.fare
                                                    .round()
                                                    .toStringAsFixed(1),
                                                style: const TextStyle(
                                                  color: Color.fromRGBO(
                                                      215, 223, 127, 1),
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      child:
                                          Image.asset('assets/images/plus.png'),
                                      onTap: () {
                                        double currentFare = viewModel.fare;
                                        setState(() {
                                          viewModel.fare = (currentFare + 10);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (customUser!.vehicleType == 'Car' ||
                                customUser.vehicleType == 'Auto')
                              Row(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Vacant Seats Available',
                                      style: TextStyle(
                                        color: Color.fromRGBO(215, 223, 127, 1),
                                        fontSize: 17,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: List.generate(viewModel.maxSeats,
                                        (index) {
                                      return Container(
                                        width: 30,
                                        height: 30,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 4),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            backgroundColor: index ==
                                                    viewModel.selectedSeats - 1
                                                ? const Color.fromRGBO(
                                                    215, 223, 127, 1)
                                                : Colors.white,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              viewModel
                                                  .setSelectedSeats(index + 1);
                                            });
                                          },
                                          child: Text(
                                            (index + 1).toString(),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color: Color.fromRGBO(
                                                    10, 34, 41, 1)),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 10),
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
