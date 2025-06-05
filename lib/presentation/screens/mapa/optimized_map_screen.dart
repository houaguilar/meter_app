// lib/presentation/screens/mapa/optimized_map_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meter_app/presentation/screens/mapa/widgets/optimized_place_search_screen.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../config/theme/theme.dart';
import '../../../domain/entities/map/location.dart';
import '../../../domain/entities/map/place_entity.dart';
import '../../blocs/map/locations_bloc.dart';
import '../../blocs/map/place/place_bloc.dart';
import '../../widgets/app_bar/app_bar_widget.dart';
import 'widgets/optimized_search_bar.dart';
import 'widgets/optimized_providers_list.dart';
import 'widgets/location_permission_dialog.dart';
import 'widgets/map_loading_overlay.dart';

class OptimizedMapScreen extends StatefulWidget {
  const OptimizedMapScreen({super.key});

  @override
  State<OptimizedMapScreen> createState() => _OptimizedMapScreenState();
}

class _OptimizedMapScreenState extends State<OptimizedMapScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {

  // Controllers y streams
  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionStream;
  Timer? _searchDebounceTimer;

  // Estado interno
  Position? _currentPosition;
  PlaceEntity? _selectedPlace; // Nueva variable para la ubicación seleccionada
  bool _isMapReady = false;
  bool _isLocationPermissionGranted = false;
  bool _isLocationLoading = true;
  String? _locationError;

  // Configuración de mapa
  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(-12.0464, -77.0428), // Lima, Perú
    zoom: 11.0,
  );

  // Configuración de ubicación optimizada
  static const LocationSettings _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 50, // Solo actualizar cada 50 metros
  );

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeLocation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _positionStream?.cancel();
    _searchDebounceTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
        _pauseLocationUpdates();
        break;
      case AppLifecycleState.resumed:
        _resumeLocationUpdates();
        break;
      case AppLifecycleState.detached:
        _stopLocationUpdates();
        break;
      default:
        break;
    }
  }

  void _navigateToSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const OptimizedPlaceSearchScreen(),
        settings: const RouteSettings(name: '/place-search'),
      ),
    );
  }

  Future<void> _initializeLocation() async {
    try {
      final permission = await _checkLocationPermission();
      setState(() {
        _isLocationPermissionGranted = permission;
        _isLocationLoading = false;
      });

      if (permission) {
        await _getCurrentLocation();
        _startLocationUpdates();
      }
    } catch (e) {
      setState(() {
        _locationError = 'Error al inicializar ubicación: $e';
        _isLocationLoading = false;
      });
    }
  }

  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Los servicios de ubicación están deshabilitados';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Permisos de ubicación denegados';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Permisos de ubicación denegados permanentemente';
    }

    return true;
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: _locationSettings,
      );

      if (mounted) {
        setState(() {
          _currentPosition = position;
        });

        // Solo mover la cámara si el mapa está listo y no hay un lugar seleccionado
        if (_isMapReady && _mapController != null && _selectedPlace == null) {
          _animateToPosition(position);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationError = 'Error al obtener ubicación: $e';
        });
      }
    }
  }

  void _startLocationUpdates() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: _locationSettings,
    ).listen(
          (Position position) {
        if (mounted) {
          setState(() {
            _currentPosition = position;
          });
        }
      },
      onError: (e) {
        if (mounted) {
          setState(() {
            _locationError = 'Error en actualizaciones de ubicación: $e';
          });
        }
      },
    );
  }

  void _pauseLocationUpdates() {
    _positionStream?.pause();
  }

  void _resumeLocationUpdates() {
    if (_isLocationPermissionGranted) {
      _positionStream?.resume();
    }
  }

  void _stopLocationUpdates() {
    _positionStream?.cancel();
    _positionStream = null;
  }

  void _animateToPosition(Position position) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 15.0,
        ),
      ),
    );
  }

  // Nuevo método para animar hacia un lugar seleccionado
  void _animateToPlace(PlaceEntity place) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(place.lat, place.lng),
          zoom: 16.0,
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() {
      _isMapReady = true;
    });

    // Aplicar tema del mapa
    _applyMapTheme();

    // Decidir qué ubicación mostrar
    if (_selectedPlace != null) {
      _animateToPlace(_selectedPlace!);
    } else if (_currentPosition != null) {
      _animateToPosition(_currentPosition!);
    }
  }

  Future<void> _applyMapTheme() async {
    try {
      // Puedes agregar un tema personalizado para el mapa aquí
      // const String mapStyle = '[{"elementType":"geometry",...}]';
      // await _mapController?.setMapStyle(mapStyle);
    } catch (e) {
      debugPrint('Error applying map theme: $e');
    }
  }

  Set<Marker> _buildMarkers(List<LocationMap> locations) {
    final markers = <Marker>{};

    // Agregar marcadores de ubicaciones de negocio
    for (final location in locations) {
      markers.add(
        Marker(
          markerId: MarkerId(location.id ?? location.title),
          position: LatLng(location.latitude, location.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(
            title: location.title,
            snippet: location.description,
            onTap: () => _showLocationDetails(location),
          ),
          onTap: () => _showLocationDetails(location),
        ),
      );
    }

    // Agregar marcador de ubicación actual
    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(
            title: 'Mi ubicación',
            snippet: 'Tu ubicación actual',
          ),
        ),
      );
    }

    // Agregar marcador del lugar seleccionado
    if (_selectedPlace != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('selected_place'),
          position: LatLng(_selectedPlace!.lat, _selectedPlace!.lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: 'Lugar seleccionado',
            snippet: _selectedPlace!.description,
          ),
        ),
      );
    }

    return markers;
  }

  void _showLocationDetails(LocationMap location) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildLocationDetailsSheet(location),
    );
  }

  Widget _buildLocationDetailsSheet(LocationMap location) {
    return Container(
      margin: const EdgeInsets.only(top: 50),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.neutral300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    location.title,
                    style: AppTypography.h4,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (location.imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        location.imageUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: AppColors.neutral100,
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 64,
                              color: AppColors.neutral400,
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 16),

                  Text(
                    'Descripción',
                    style: AppTypography.h6,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    location.description,
                    style: AppTypography.bodyMedium,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Dirección',
                    style: AppTypography.h6,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    location.address,
                    style: AppTypography.bodyMedium,
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Action buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.border),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Implementar WhatsApp
                      },
                      icon: const Icon(Icons.message),
                      label: const Text('WhatsApp'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Implementar llamada
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text('Llamar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBarWidget(titleAppBar: 'Proveedores'),
      body: Stack(
        children: [
          // Mapa con listener del PlaceBloc
          BlocListener<PlaceBloc, PlaceState>(
            listener: (context, state) {
              if (state is OptimizedPlaceSelected) {
                setState(() {
                  _selectedPlace = state.place;
                });

                // Animar hacia el lugar seleccionado si el mapa está listo
                if (_isMapReady && _mapController != null) {
                  _animateToPlace(state.place);
                }
              }
            },
            child: _buildMapContent(),
          ),

          // Barra de búsqueda
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: OptimizedSearchBar(
              onSearchTap: _navigateToSearch,
            ),
          ),

          // Lista de proveedores
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildProvidersSection(),
          ),

          // Overlay de carga del mapa
          if (!_isMapReady || _isLocationLoading)
            const MapLoadingOverlay(),
        ],
      ),
      floatingActionButton: _buildLocationFAB(),
    );
  }

  Widget _buildMapContent() {
    if (!_isLocationPermissionGranted && !_isLocationLoading) {
      return LocationPermissionDialog(
        onRetry: _initializeLocation,
      );
    }

    return BlocBuilder<LocationsBloc, LocationsState>(
      builder: (context, state) {
        Set<Marker> markers = {};

        if (state is LocationsLoaded) {
          markers = _buildMarkers(state.locations);
        }

        return GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: _selectedPlace != null
              ? CameraPosition(
            target: LatLng(_selectedPlace!.lat, _selectedPlace!.lng),
            zoom: 16.0,
          )
              : _currentPosition != null
              ? CameraPosition(
            target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            zoom: 15.0,
          )
              : _defaultPosition,
          markers: markers,
          myLocationEnabled: false, // Usamos nuestro propio marcador
          myLocationButtonEnabled: false, // Usamos nuestro propio FAB
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: true,
          rotateGesturesEnabled: true,
          scrollGesturesEnabled: true,
          tiltGesturesEnabled: true,
          zoomGesturesEnabled: true,
          buildingsEnabled: true,
          trafficEnabled: false, // Ahorra llamadas API
          mapType: MapType.normal,
        );
      },
    );
  }

  Widget _buildProvidersSection() {
    return Container(
      height: 280,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.neutral300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header con información del lugar seleccionado
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Proveedores Recomendados',
                      style: AppTypography.h5.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.store,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ],
                ),

                // Mostrar información del lugar seleccionado
                if (_selectedPlace != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.success.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _selectedPlace!.description,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedPlace = null;
                            });
                            // Regresar a la ubicación actual
                            if (_currentPosition != null && _mapController != null) {
                              _animateToPosition(_currentPosition!);
                            }
                          },
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Lista de proveedores
          const Expanded(
            child: OptimizedProvidersList(),
          ),
        ],
      ),
    );
  }

  Widget? _buildLocationFAB() {
    if (!_isLocationPermissionGranted) return null;

    return FloatingActionButton(
      onPressed: () {
        if (_currentPosition != null) {
          setState(() {
            _selectedPlace = null; // Limpiar lugar seleccionado
          });
          _animateToPosition(_currentPosition!);
        } else {
          _getCurrentLocation();
        }
      },
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      child: _isLocationLoading
          ? const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
        ),
      )
          : const Icon(Icons.my_location),
    );
  }
}