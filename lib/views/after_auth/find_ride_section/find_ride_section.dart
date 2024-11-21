import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:waygo/view_models/find_ride_view_models/find_ride_view_model.dart';

import 'package:waygo/widgets/search_text_field.dart';

class FindRideSection extends ConsumerStatefulWidget {
  const FindRideSection({super.key});

  @override
  _FindRideSectionState createState() => _FindRideSectionState();
}

class _FindRideSectionState extends ConsumerState<FindRideSection> {
  final MapController _mapController = MapController();
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mounted) {
        final viewModel = ref.read(findRideViewModelProvider);
        viewModel.initialize();
        viewModel.checkPermissions();
        viewModel.getCurrentLocation(_mapController, context);
      }
    });
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
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
    final viewModel = ref.watch(findRideViewModelProvider);
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
            bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 40 : 0,
            left: 0,
            right: 0,
            child: SingleChildScrollView(
              child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.472,
                  child: DraggableScrollableSheet(
                    initialChildSize: 0.99,
                    minChildSize: 0.57,
                    maxChildSize: 1,
                    snap: true,
                    snapSizes: const [0.57, 0.99],
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
                              onDestinationSelected: (LatLng origin) async {},
                              isForOfferRide: false,
                              mapController: _mapController,
                              isOriginField: true,
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
                              mapController: _mapController,
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
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Select No. of Passengers',
                                    style: TextStyle(
                                      color: Color.fromRGBO(215, 223, 127, 1),
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
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
                            const SizedBox(height: 15),
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
                                  onPressed: () {
                                    viewModel.createAndSaveRideRequest(ref);
                                  },
                                  child: const Row(
                                    children: [
                                      Icon(Icons.search, color: Colors.black),
                                      SizedBox(width: 5),
                                      Text('Search Ride',
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
