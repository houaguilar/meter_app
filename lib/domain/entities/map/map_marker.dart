

import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapMarker extends Equatable {
  final LatLng position;
  final String title;
  final String snippet;

  const MapMarker({required this.position, required this.title, required this.snippet});

  @override
  List<Object?> get props => [position, title, snippet];
}