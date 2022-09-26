import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lora_telemetry/controllers/power_meter.dart';
import 'package:lora_telemetry/handlers/firestore_handler.dart';
import 'package:lora_telemetry/handlers/location_handler.dart';
import 'package:lora_telemetry/widgets/filter.dart';

import '../widgets/power_meter_details.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller = Completer();
  final LocationHandler _locationHandler = LocationHandler();
  final FirestoreHandler _firestoreHandler = FirestoreHandler();

  Future<String> _getMapStyle() async {
    return await DefaultAssetBundle.of(context)
        .loadString('assets/map_style.json');
  }

  Future<CameraPosition> getCameraPosition() async {
    return CameraPosition(
      target: await _locationHandler.getCurrentLocation(),
      zoom: 15,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("LoRa Telemetry"),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: ((BuildContext context) => const Filter()),
            ).then(
              (value) => setState(() {}),
            );
          },
          child: const Icon(Icons.filter_alt),
        ),
        body: FutureBuilder<CameraPosition>(
          future: getCameraPosition(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              CameraPosition cameraPosition = snapshot.data!;
              return StreamBuilder<List<PowerMeter>>(
                stream: _firestoreHandler.getFilteredMeters(context),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    Set<Marker>? markersToSet = snapshot.data
                        ?.map(
                          (PowerMeter meter) => Marker(
                            markerId: MarkerId(meter.id),
                            position: meter.geolocation,
                            onTap: () => showDialog<String>(
                              context: context,
                              builder: (context) => PowerMeterDetails(
                                meter,
                              ),
                            ),
                          ),
                        )
                        .toSet();
                    return GoogleMap(
                      initialCameraPosition: cameraPosition,
                      myLocationEnabled: true,
                      mapToolbarEnabled: false,
                      zoomControlsEnabled: false,
                      onMapCreated: (GoogleMapController controller) async {
                        _controller.complete(controller);
                        controller.setMapStyle(await _getMapStyle());
                      },
                      markers: markersToSet ?? <Marker>{},
                    );
                  } else {
                    return Center(
                      child: LocationHandler().serviceEnabled != null &&
                              !LocationHandler().serviceEnabled!
                          ? const Text(
                              'Ative a localização do seu dispositivo!',
                            )
                          : const CircularProgressIndicator(),
                    );
                  }
                },
              );
            } else if (snapshot.hasError) {
              return Center(
                child: ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Icon(Icons.refresh),
                ),
              );
            } else {
              return Center(
                child: LocationHandler().serviceEnabled != null &&
                        !LocationHandler().serviceEnabled!
                    ? const Text(
                        'Ative a localização do seu dispositivo!',
                      )
                    : const CircularProgressIndicator(),
              );
            }
          },
        ));
  }
}
