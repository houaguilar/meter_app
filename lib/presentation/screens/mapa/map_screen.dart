import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meter_app/presentation/screens/widgets/shared/app_bar_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../domain/entities/map/location.dart';
import '../../blocs/map/locations_bloc.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;

  final TextEditingController _addressController = TextEditingController();
  bool _useCurrentLocation = false;
  double _searchRadius = 5.0;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      status = await Permission.location.request();
    }

    if (status.isGranted) {
      _getCurrentLocation();
    } else {
      _showPermissionDeniedDialog();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high
      );
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }

      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((Position position) {
        if (mounted) {
          setState(() {
            _currentPosition = position;
          });

          if (_mapController != null) {
            _mapController!.animateCamera(
              CameraUpdate.newLatLng(
                LatLng(position.latitude, position.longitude),
              ),
            );
          }
        }
      });
    } catch (e) {
      _showLocationError(e.toString());
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permiso de ubicación denegado'),
        content: const Text('La aplicación necesita acceso a tu ubicación para mostrar el mapa correctamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await openAppSettings();
            },
            child: const Text('Abrir configuración'),
          ),
        ],
      ),
    );
  }

  void _showLocationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al obtener la ubicación: $message')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(titleAppBar: 'Proveedores',),
      body: BlocConsumer<LocationsBloc, LocationsState>(
        listener: (context, state) {
          if (state is LocationsError) {
            _showLocationError(state.message);
          }
        },
        builder: (context, state) {
          if (state is LocationsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is LocationsLoaded) {
            Set<Marker> markers = state.locations.map((location) {
              return Marker(
                markerId: MarkerId(location.id),
                position: LatLng(location.latitude, location.longitude),
                infoWindow: InfoWindow(
                  title: location.title,
                  snippet: location.description,
                  onTap: () => _showLocationDetails(location),
                ),
              );
            }).toSet();

            if (_currentPosition != null) {
              markers.add(
                Marker(
                  markerId: const MarkerId('current_location'),
                  position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                ),
              );
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _useCurrentLocation,
                        onChanged: (value) {
                          setState(() {
                            _useCurrentLocation = value!;
                          });
                        },
                      ),
                      const Text('Ubicación Actual'),
                      const SizedBox(width: 20),
                      Expanded(
                        child: TextField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            hintText: 'Ingresar Dirección',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Alcance de Búsqueda'),
                          const SizedBox(width: 20),
                          DropdownButton<double>(
                            value: _searchRadius,
                            items: <double>[1, 5, 10, 20]
                                .map<DropdownMenuItem<double>>((double value) {
                              return DropdownMenuItem<double>(
                                value: value,
                                child: Text('$value km'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _searchRadius = value!;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10,),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.search),
                        label: const Text('Buscar'),
                        onPressed: () {
                          // Acción al presionar el botón de búsqueda
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GoogleMap(
                    onMapCreated: (controller) => _mapController = controller,
                    initialCameraPosition: _currentPosition != null
                        ? CameraPosition(
                      target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      zoom: 14,
                    )
                        : const CameraPosition(target: LatLng(0, 0), zoom: 14),
                    markers: markers,
                  ),
                )
              ],
            );

          } else {
            return Container();
          }
        },
      ),
    );
  }

  void _showLocationDetails(Location location) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Image.asset('assets/images/ferreteria.png', width: 200, height: 200,),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(location.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(location.description),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      const url = 'https://wa.me/+51910297550}?text=Hola';
                      _launchURL(url);
                    },
                    child: const Text('WhatsApp'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      const url = 'tel:+51910297550';
                      _launchURL(url);
                    },
                    child: const Text('Llamar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                    },
                    child: const Text('Más Info'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'No se pudo lanzar $url';
    }
  }
}
