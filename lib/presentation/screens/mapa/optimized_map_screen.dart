import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meter_app/presentation/screens/mapa/widgets/optimized_place_search_screen.dart';

import '../../../config/theme/theme.dart';
import '../../../domain/entities/map/location.dart';
import '../../../domain/entities/map/location_with_distance.dart';
import '../../../domain/entities/map/place_entity.dart';
import '../../blocs/map/locations_bloc.dart';
import '../../blocs/map/place/place_bloc.dart';
import '../../widgets/app_bar/app_bar_widget.dart';
import '../home/shared/quote/quote_project_selection_screen.dart';
import 'detail/location_detail_screen.dart';
import 'widgets/optimized_search_bar.dart';
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
  PageController? _pageController;

  // Estado interno
  Position? _currentPosition;
  PlaceEntity? _selectedPlace;
  bool _isMapReady = false;
  bool _isLocationPermissionGranted = false;
  bool _isLocationLoading = true;
  String? _locationError;

  LocationWithDistance? _selectedLocation;
  List<LocationWithDistance> _nearbyLocations = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController(viewportFraction: 0.85);
    _initializeLocation();
   // _loadProviders(); // Cargar proveedores
    context.read<LocationsBloc>().add(LoadLocations());

  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _positionStream?.cancel();
    _searchDebounceTimer?.cancel();
    _mapController?.dispose();
    _pageController?.dispose();
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

  // MÉTODO BUILD PRINCIPAL
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBarWidget(titleAppBar: 'Proveedores'),
      body: Stack(
        children: [
          BlocListener<PlaceBloc, PlaceState>(
            listener: (context, state) {
              if (state is OptimizedPlaceSelected) {
                setState(() {
                  _selectedPlace = state.place;
                  _selectedLocation = null;
                });

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

          // FAB de ubicación
          Positioned(
            bottom: 320,
            right: 16,
            child: _buildEnhancedLocationFAB(),
          ),

          // Carrusel de proveedores (SIN expandir/colapsar)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildNearbyLocationsCarousel(),
          ),

          if (!_isMapReady || _isLocationLoading)
            const MapLoadingOverlay(),
        ],
      ),
    );
  }

  // INICIALIZACIÓN DE UBICACIÓN
  Future<void> _initializeLocation() async {
    try {
      setState(() {
        _isLocationLoading = true;
        _locationError = null;
      });

      final permission = await _checkLocationPermission();
      if (!permission) {
        setState(() {
          _isLocationPermissionGranted = false;
          _isLocationLoading = false;
        });
        return;
      }

      setState(() {
        _isLocationPermissionGranted = true;
      });

      await _getCurrentLocation();
      _startLocationUpdates();

    } catch (e) {
      debugPrint('Error initializing location: $e');
      setState(() {
        _locationError = e.toString();
        _isLocationLoading = false;
      });
    }
  }

  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _currentPosition = position;
        _isLocationLoading = false;
      });

      if (_isMapReady && _mapController != null) {
        _animateToPosition(position);
      }

      final locationsState = context.read<LocationsBloc>().state;
      if (locationsState is LocationsLoaded) {
        _calculateNearbyLocations(locationsState.locations);
      }

    } catch (e) {
      debugPrint('Error getting current location: $e');
      setState(() {
        _locationError = 'No se pudo obtener la ubicación actual';
        _isLocationLoading = false;
      });
    }
  }

  void _startLocationUpdates() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Actualizar cada 10 metros
    );

    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
          (Position position) {
        setState(() {
          _currentPosition = position;
        });
      },
      onError: (error) {
        debugPrint('Error in location stream: $error');
      },
    );
  }

  void _pauseLocationUpdates() {
    _positionStream?.pause();
  }

  void _resumeLocationUpdates() {
    _positionStream?.resume();
  }

  void _stopLocationUpdates() {
    _positionStream?.cancel();
    _positionStream = null;
  }

  Widget _buildNearbyLocationsCarousel() {
    return BlocListener<LocationsBloc, LocationsState>(
      listener: (context, state) {
        if (state is LocationsLoaded) {
          // Calcular ubicaciones cercanas cuando se cargan las ubicaciones
          _calculateNearbyLocations(state.locations);
        }
      },
      child: _nearbyLocations.isEmpty
          ? const SizedBox.shrink()
          : Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle del carrusel
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.near_me,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ubicaciones cercanas (${_nearbyLocations.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Lista de ubicaciones
            SizedBox(
              height: 170,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _nearbyLocations.length,
                itemBuilder: (context, index) {
                  final location = _nearbyLocations[index];
                  final isSelected = _selectedLocation?.id == location.id;

                  return Container(
                    width: 280,
                    margin: EdgeInsets.only(
                      right: index == _nearbyLocations.length - 1 ? 0 : 12,
                    ),
                    child: _buildLocationCard(location, isSelected),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(LocationWithDistance location, bool isSelected) {
    return GestureDetector(
      onTap: () => _onLocationTapped(location),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.secondary.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.15)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  // Imagen/Icono
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.primary,
                    ),
                    child: location.imageUrl?.isNotEmpty == true
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        location.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.location_on,
                            color: AppColors.primary,
                            size: 24,
                          );
                        },
                      ),
                    )
                        : Icon(
                      Icons.location_on,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 15),

                  // Información
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          location.title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        if (location.distanceKm != null)
                          Row(
                            children: [
                              Icon(
                                Icons.near_me,
                                size: 12,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${location.distanceKm!.toStringAsFixed(1)}km',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 4),

                        if (location.description.isNotEmpty)
                          Text(
                            location.description,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.all(0),
                child: Row(
                  children: [
                    // Botón Ver Productos
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _navigateToProviderDetail(location),
                            child: Center(
                              child: Text(
                                'Ver Productos',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Botón Cotizar
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _showQuoteDialog(location),
                            child: Center(
                              child: Text(
                                'Cotizar',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  void _onLocationTapped(LocationWithDistance location) {
    setState(() {
      _selectedLocation = location;
      _selectedPlace = null; // Limpiar selección de búsqueda
    });

    // Animar el mapa hacia la ubicación seleccionada
    _animateToLocation(location);
  }

  // 🆕 SOLO AGREGAR: Calcular ubicaciones cercanas
  void _calculateNearbyLocations(List<LocationMap> allLocations) {
    if (_currentPosition == null) return;

    final locationsWithDistance = <LocationWithDistance>[];

    for (final location in allLocations) {
      // FILTRO IMPORTANTE: Solo mostrar proveedores activos
      if (!location.isActive) {
        continue;
      }

      final distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        location.latitude,
        location.longitude,
      ) / 1000; // Convertir a km

      // Solo incluir ubicaciones dentro de 25km
      if (distance <= 25.0) {
        locationsWithDistance.add(LocationWithDistance.fromLocation(
          location,
          distanceKm: distance,
        ));
      }
    }

    // Ordenar por distancia y tomar las 10 más cercanas
    locationsWithDistance.sort((a, b) => a.distanceKm!.compareTo(b.distanceKm!));

    setState(() {
      _nearbyLocations = locationsWithDistance.take(10).toList();
    });
  }

  // 🆕 SOLO AGREGAR: Animar a ubicación específica
  Future<void> _animateToLocation(LocationWithDistance location) async {
    if (_mapController == null) return;

    await _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(location.latitude, location.longitude),
          zoom: 16.0,
        ),
      ),
    );
  }

  // NAVEGACIÓN Y ANIMACIONES DEL MAPA
  void _navigateToSearch() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
        const OptimizedPlaceSearchScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  Future<void> _animateToPlace(PlaceEntity place) async {
    if (_mapController == null) return;

    await _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(place.lat, place.lng),
          zoom: 16.0,
        ),
      ),
    );
  }

  Future<void> _animateToPosition(Position position) async {
    if (_mapController == null) return;

    await _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 15.0,
        ),
      ),
    );
  }

  void _goToCurrentLocation() async {
    if (_currentPosition != null) {
      _animateToPosition(_currentPosition!);
    } else if (_currentPosition != null) {
      _animateToPosition(_currentPosition!);
    }
  }

  Future<void> _applyMapTheme() async {
    try {
      // Tema personalizado del mapa si es necesario
    } catch (e) {
      debugPrint('Error applying map theme: $e');
    }
  }

  // CONTENIDO DEL MAPA
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

        CameraPosition initialPosition;

        if (_selectedPlace != null) {
          initialPosition = CameraPosition(
            target: LatLng(_selectedPlace!.lat, _selectedPlace!.lng),
            zoom: 16.0,
          );
        } else if (_selectedLocation != null) {
          // 🆕 AGREGAR: Soporte para ubicación seleccionada del carrusel
          initialPosition = CameraPosition(
            target: LatLng(_selectedLocation!.latitude, _selectedLocation!.longitude),
            zoom: 16.0,
          );
        } else if (_currentPosition != null) {
          initialPosition = CameraPosition(
            target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            zoom: 15.0,
          );
        } else {
          // 🔧 CORREGIDO: Position por defecto solo como fallback
          initialPosition = const CameraPosition(
            target: LatLng(-12.0464, -77.0428), // Lima, Perú como fallback
            zoom: 12.0,
          );
        }

        return GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: initialPosition,
          markers: markers,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: true,
          rotateGesturesEnabled: true,
          scrollGesturesEnabled: true,
          tiltGesturesEnabled: true,
          zoomGesturesEnabled: true,
          buildingsEnabled: true,
          trafficEnabled: false,
          mapType: MapType.normal,
        );
      },
    );
  }

  Set<Marker> _buildMarkers(List<LocationMap> locations) {
    final markers = <Marker>{};

    for (final location in locations) {
      // FILTRO IMPORTANTE: Solo mostrar markers de proveedores aprobados y activos
      if (!location.verificationStatus.isApproved || !location.isActive) {
        continue;
      }

      final isSelected = _selectedLocation?.id == location.id;

      markers.add(
        Marker(
          markerId: MarkerId(location.id ?? ''),
          position: LatLng(location.latitude, location.longitude),
          icon: isSelected
              ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)
              : BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(
            title: location.title,
            snippet: location.description ?? '',
          ),
          onTap: () {
            // 🆕 También actualizar selección desde el mapa
            if (location is LocationWithDistance) {
              setState(() {
                _selectedLocation = location;
              });
            }
            _navigateToLocationDetail(location);
          },
        ),
      );
    }

    // Agregar marker de ubicación actual si existe
    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(
            title: 'Mi ubicación',
            snippet: 'Ubicación actual',
          ),
        ),
      );
    }

    return markers;
  }

  void _navigateToLocationDetail(LocationMap location) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LocationDetailScreen(location: location,)
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _applyMapTheme();

    setState(() {
      _isMapReady = true;
    });

    // Animar a la ubicación actual si ya la tenemos
    if (_currentPosition != null) {
      _animateToPosition(_currentPosition!);

      final locationsState = context.read<LocationsBloc>().state;
      if (locationsState is LocationsLoaded) {
        _calculateNearbyLocations(locationsState.locations);
      }
    }
  }

  // FAB MEJORADO CON ESTADOS VISUALES
  Widget _buildEnhancedLocationFAB() {
    return Hero(
      tag: 'location_fab',
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.primary,
          elevation: 0,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _isLocationLoading ? null : _goToCurrentLocation,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: _currentPosition != null
                    ? Border.all(color: AppColors.white.withOpacity(0.3), width: 2)
                    : null,
              ),
              child: _buildLocationIcon(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationIcon() {
    return Icon(
      _isLocationLoading
          ? Icons.hourglass_empty
          : _currentPosition != null
          ? Icons.my_location
          : Icons.location_searching,
      color: AppColors.white,
      size: 24,
    );
  }

  void _navigateToProviderDetail(LocationWithDistance location) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LocationDetailScreen(location: location,),
      ),
    );
  }

  void _showQuoteDialog(LocationWithDistance location) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuoteProjectSelectionScreen(
          providerName: location.title,
          providerImageUrl: location.imageUrl ?? "",
        ),
      ),
    );
  }

}
