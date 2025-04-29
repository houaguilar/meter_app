import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPicker extends StatelessWidget {
  final LatLng? pickedLocation;
  final Function(LatLng) onLocationPicked;

  const LocationPicker({
    required this.pickedLocation,
    required this.onLocationPicked,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(-12.0464, -77.0428),
          zoom: 14,
        ),
        onTap: onLocationPicked,
        markers: pickedLocation == null
            ? {}
            : {
          Marker(
            markerId: const MarkerId('selected-location'),
            position: pickedLocation!,
          ),
        },
      ),
    );
  }
}
