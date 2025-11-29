import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../config/theme/app_colors.dart';

/// Modal fullscreen para seleccionar ubicación en el mapa
///
/// Muestra un mapa grande sin interferencias del scroll
/// Permite al usuario navegar y seleccionar una ubicación con precisión
class MapSelectionModal extends StatefulWidget {
  final LatLng initialLocation;
  final String? initialAddress;

  const MapSelectionModal({
    super.key,
    required this.initialLocation,
    this.initialAddress,
  });

  @override
  State<MapSelectionModal> createState() => _MapSelectionModalState();
}

class _MapSelectionModalState extends State<MapSelectionModal> {
  late LatLng _selectedLocation;
  late String _selectedAddress;
  bool _isLoadingAddress = false;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    _selectedAddress = widget.initialAddress ?? 'Obteniendo dirección...';

    // Si no hay dirección inicial, obtenerla
    if (widget.initialAddress == null || widget.initialAddress!.isEmpty) {
      _getAddressFromLatLng(_selectedLocation);
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  /// Obtiene la dirección desde las coordenadas
  Future<void> _getAddressFromLatLng(LatLng position) async {
    setState(() {
      _isLoadingAddress = true;
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address = [
          place.street,
          place.locality,
          place.administrativeArea,
          place.country,
        ].where((element) => element != null && element.isNotEmpty).join(', ');

        setState(() {
          _selectedAddress = address;
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      setState(() {
        _selectedAddress = 'Dirección no disponible';
        _isLoadingAddress = false;
      });
    }
  }

  /// Maneja el tap en el mapa para seleccionar nueva ubicación
  void _onMapTap(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
    _getAddressFromLatLng(position);
  }

  /// Confirma la selección y cierra el modal
  void _confirmSelection() {
    Navigator.of(context).pop({
      'location': _selectedLocation,
      'address': _selectedAddress,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Seleccionar Ubicación',
          style: TextStyle(
            fontSize: 20,
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primaryMetraShop,
        foregroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // Mapa fullscreen
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation,
              zoom: 16,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            onTap: _onMapTap,
            // Configuración para navegación sin interferencias
            zoomControlsEnabled: true,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            mapType: MapType.normal,
            compassEnabled: true,
            rotateGesturesEnabled: true,
            scrollGesturesEnabled: true,
            tiltGesturesEnabled: true,
            zoomGesturesEnabled: true,
            // Sin interferencias de gestos
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            },
            markers: {
              Marker(
                markerId: const MarkerId('selected-location'),
                position: _selectedLocation,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed,
                ),
                draggable: true,
                onDragEnd: (LatLng position) {
                  setState(() {
                    _selectedLocation = position;
                  });
                  _getAddressFromLatLng(position);
                },
              ),
            },
          ),

          // Información de dirección en la parte superior
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.location_on,
                        color: AppColors.blueMetraShop,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ubicación seleccionada',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.primaryMetraShop,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_isLoadingAddress)
                    Row(
                      children: const [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.blueMetraShop,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Obteniendo dirección...',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.greyTextColor,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      _selectedAddress,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  Text(
                    'Lat: ${_selectedLocation.latitude.toStringAsFixed(6)}, '
                    'Lng: ${_selectedLocation.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.greyTextColor,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Instrucciones en la parte media
          Positioned(
            left: 16,
            right: 16,
            bottom: 100,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.blueMetraShop.withOpacity(0.95),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: const [
                  Icon(
                    Icons.touch_app,
                    color: AppColors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Toca el mapa o arrastra el marcador para seleccionar',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Botón de confirmar en la parte inferior
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: _confirmSelection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueMetraShop,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.check_circle, color: AppColors.white),
                      SizedBox(width: 8),
                      Text(
                        'Confirmar Ubicación',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
