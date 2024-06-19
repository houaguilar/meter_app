import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(-12.028645160710196, -76.9633805674338),
    zoom: 14,
  );

  final List<Marker> myMarker = [];
  final List<Marker> markerList = [
    const Marker(
      markerId: MarkerId('My position'),
      position: LatLng(-12.028645160710196, -76.9633805674338),
      infoWindow: InfoWindow(title: 'My Position'),
    ),
  ];

  @override
  void initState() {
    super.initState();
    myMarker.addAll(markerList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location_alt),
            onPressed: () {
              // Acción para agregar un nuevo marcador
              _addMarker();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,
            mapType: MapType.normal,
            markers: Set<Marker>.of(myMarker),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FloatingActionButton(
                onPressed: () async {
                  // Acción para centrar el mapa en la posición inicial
                  final GoogleMapController controller = await _controller.future;
                  controller.animateCamera(CameraUpdate.newCameraPosition(_initialPosition));
                },
                child: const Icon(Icons.my_location),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addMarker() {
    setState(() {
      myMarker.add(
        Marker(
          markerId: MarkerId(DateTime.now().toString()),
          position: LatLng(
            -12.028645160710196 + myMarker.length * 0.001,
            -76.9633805674338 + myMarker.length * 0.001,
          ),
          infoWindow: InfoWindow(title: 'Marker ${myMarker.length + 1}'),
        ),
      );
    });
  }
}
