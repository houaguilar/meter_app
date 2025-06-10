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
  int _currentProviderIndex = 0;

  // Configuración de mapa
  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(-12.0464, -77.0428), // Lima, Perú
    zoom: 11.0,
  );

  // Configuración de ubicación optimizada
  static const LocationSettings _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 50,
  );

  // Lista de proveedores
  final List<ProviderModel> _providers = [
    ProviderModel(
      name: 'SIDEREXPRESS',
      description: 'Venta de materiales de construcción online, cotiza y compra desde tu celular',
      imageUrl: 'assets/images/express_img.png',
      salesCount: 567,
      rating: 4.8,
      phone: '51943529146',
      category: 'Ferretería',
      distance: '2.3 km',
      pdfUrl: 'https://yndbqhfzxxoxsnxizoab.supabase.co/storage/v1/object/public/pdf/materiales.pdf?t=2024-11-12T23%3A20%3A58.916Z',
    ),
    ProviderModel(
      name: 'EQUIPCONSTRUYE',
      description: 'Venta de materiales de construcción online, cotiza y compra desde tu celular',
      imageUrl: 'assets/images/equip_img.png',
      salesCount: 432,
      rating: 4.6,
      phone: '51912188792',
      category: 'Equipos',
      distance: '3.7 km',
      pdfUrl: 'https://yndbqhfzxxoxsnxizoab.supabase.co/storage/v1/object/public/pdf/materiales.pdf?t=2024-11-12T23%3A20%3A58.916Z',
    ),
    ProviderModel(
      name: 'MATERIALES LIMA',
      description: 'Especialistas en cemento, ladrillos y agregados para construcción',
      imageUrl: 'assets/images/materials_img.png',
      salesCount: 289,
      rating: 4.4,
      phone: '51987654321',
      category: 'Materiales',
      distance: '5.1 km',
      pdfUrl: 'https://yndbqhfzxxoxsnxizoab.supabase.co/storage/v1/object/public/pdf/materiales.pdf?t=2024-11-12T23%3A20%3A58.916Z',
    ),
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController(viewportFraction: 0.85);
    _initializeLocation();
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

    _applyMapTheme();

    if (_selectedPlace != null) {
      _animateToPlace(_selectedPlace!);
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

  Set<Marker> _buildMarkers(List<LocationMap> locations) {
    final markers = <Marker>{};

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
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.neutral300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
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
                  Text('Descripción', style: AppTypography.h6),
                  const SizedBox(height: 8),
                  Text(location.description, style: AppTypography.bodyMedium),
                  const SizedBox(height: 16),
                  Text('Dirección', style: AppTypography.h6),
                  const SizedBox(height: 8),
                  Text(location.address, style: AppTypography.bodyMedium),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
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
          BlocListener<PlaceBloc, PlaceState>(
            listener: (context, state) {
              if (state is OptimizedPlaceSelected) {
                setState(() {
                  _selectedPlace = state.place;
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

          // Carousel de proveedores - Nueva implementación
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildProvidersCarousel(),
          ),

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

  // NUEVA IMPLEMENTACIÓN: Carousel horizontal de proveedores
  Widget _buildProvidersCarousel() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          // Header con título y lugar seleccionado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.store_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Proveedores Recomendados',
                      style: AppTypography.h6.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    // Indicador de página
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_currentProviderIndex + 1}/${_providers.length}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                // Información del lugar seleccionado
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
                          size: 14,
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
                            if (_currentPosition != null && _mapController != null) {
                              _animateToPosition(_currentPosition!);
                            }
                          },
                          child: Icon(
                            Icons.close,
                            size: 14,
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

          // Carousel de cards
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentProviderIndex = index;
                });
              },
              itemCount: _providers.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: _buildProviderCard(_providers[index], index == _currentProviderIndex),
                );
              },
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProviderCard(ProviderModel provider, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      transform: Matrix4.identity()..scale(isActive ? 1.0 : 0.95),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? AppColors.primary.withOpacity(0.3)
                : AppColors.border.withOpacity(0.5),
            width: isActive ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isActive ? 0.15 : 0.08),
              blurRadius: isActive ? 12 : 8,
              offset: Offset(0, isActive ? 6 : 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Imagen del proveedor
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.border.withOpacity(0.5),
                ),
                color: AppColors.neutral50,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  provider.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.neutral100,
                      child: Icon(
                        Icons.store,
                        color: AppColors.neutral400,
                        size: 24,
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Información del proveedor
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nombre y rating
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          provider.name,
                          style: AppTypography.labelLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 12,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              provider.rating.toString(),
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Categoría y distancia
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          provider.category,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.location_on,
                        size: 12,
                        color: AppColors.neutral400,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        provider.distance,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.neutral500,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.message,
                          label: 'WhatsApp',
                          color: Colors.green,
                          onPressed: () => _launchWhatsApp(provider.phone),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.description,
                          label: 'Cotizar',
                          color: AppColors.secondary,
                          onPressed: () => _launchQuote(provider.phone, provider.pdfUrl),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: color,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchWhatsApp(String phone) async {
    // Implementar lanzamiento de WhatsApp
  }

  Future<void> _launchQuote(String phone, String pdfUrl) async {
    // Implementar lanzamiento de cotización
  }

  Widget? _buildLocationFAB() {
    if (!_isLocationPermissionGranted) return null;

    return FloatingActionButton(
      onPressed: () {
        if (_currentPosition != null) {
          setState(() {
            _selectedPlace = null;
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

// Modelo de datos para proveedores
class ProviderModel {
  final String name;
  final String description;
  final String imageUrl;
  final int salesCount;
  final double rating;
  final String phone;
  final String category;
  final String distance;
  final String pdfUrl;

  ProviderModel({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.salesCount,
    required this.rating,
    required this.phone,
    required this.category,
    required this.distance,
    required this.pdfUrl,
  });
}