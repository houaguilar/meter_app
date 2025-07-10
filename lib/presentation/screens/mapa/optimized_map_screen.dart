// lib/presentation/screens/mapa/optimized_map_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meter_app/presentation/screens/mapa/widgets/optimized_place_search_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool _isCarouselExpanded = true; // Nueva variable para carrusel colapsible

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

  // MÉTODO BUILD ACTUALIZADO CON SOLUCIÓN UX
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

          // FAB adaptivo
          _buildAdaptiveFAB(),

          // Carrusel colapsible
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildCollapsibleCarousel(),
          ),

          if (!_isMapReady || _isLocationLoading)
            const MapLoadingOverlay(),
        ],
      ),
    );
  }

  // FAB ADAPTIVO QUE RESPONDE AL ESTADO DEL CARRUSEL
  Widget _buildAdaptiveFAB() {
    double bottomPosition = _isCarouselExpanded ? 240 : 100;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      bottom: bottomPosition,
      right: 16,
      child: _buildEnhancedLocationFAB(),
    );
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
              child: _buildFABContent(),
            ),
          ),
        ),
      ),
    );
  }

  // CONTENIDO DEL FAB SEGÚN ESTADO
  Widget _buildFABContent() {
    if (_isLocationLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
        ),
      );
    }

    if (_locationError != null) {
      return const Icon(
        Icons.location_off,
        color: AppColors.white,
        size: 24,
      );
    }

    return Icon(
      _currentPosition != null ? Icons.my_location : Icons.location_searching,
      color: AppColors.white,
      size: 24,
    );
  }

  // CARRUSEL COLAPSIBLE
  Widget _buildCollapsibleCarousel() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: _isCarouselExpanded ? 220 : 80,
      decoration: BoxDecoration(
        color: AppColors.surface,
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
        children: [
          _buildCarouselHandle(),
          if (_isCarouselExpanded)
            Expanded(child: _buildProvidersCarousel()),
          if (!_isCarouselExpanded)
            _buildCollapsedCarousel(),
        ],
      ),
    );
  }

  // HANDLE PARA COLAPSAR/EXPANDIR
  Widget _buildCarouselHandle() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isCarouselExpanded = !_isCarouselExpanded;
        });
      },
      child: Container(
        height: 40,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.neutral300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 4),
            if (!_isCarouselExpanded)
              Text(
                'Ver proveedores',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // VISTA COLAPSADA DEL CARRUSEL
  Widget _buildCollapsedCarousel() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Icon(
            Icons.store_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '${_providers.length} proveedores disponibles',
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.keyboard_arrow_up,
            color: AppColors.neutral600,
            size: 20,
          ),
        ],
      ),
    );
  }

  // MÉTODO MEJORADO PARA IR A UBICACIÓN ACTUAL
  void _goToCurrentLocation() {
    if (_currentPosition != null && _mapController != null) {
      _animateToPosition(_currentPosition!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.white, size: 20),
              SizedBox(width: 8),
              Text('Mostrando tu ubicación'),
            ],
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
          margin: EdgeInsets.only(
            bottom: _isCarouselExpanded ? 240 : 100,
            left: 16,
            right: 16,
          ),
        ),
      );
    } else if (!_isLocationLoading) {
      _initializeLocation();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              ),
              SizedBox(width: 8),
              Text('Obteniendo ubicación...'),
            ],
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primary,
          margin: EdgeInsets.only(
            bottom: _isCarouselExpanded ? 240 : 100,
            left: 16,
            right: 16,
          ),
        ),
      );
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

      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );

        if (mounted) {
          setState(() {
            _currentPosition = position;
            _isLocationLoading = false;
          });

          _startLocationUpdates();
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLocationLoading = false;
            _locationError = 'No se pudo obtener la ubicación: $e';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLocationLoading = false;
          _locationError = 'Error al verificar ubicación: $e';
        });
      }
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
        } else if (_currentPosition != null) {
          initialPosition = CameraPosition(
            target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            zoom: 15.0,
          );
        } else {
          initialPosition = _defaultPosition;
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
                  Text(
                    location.description ?? 'Sin descripción disponible',
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // CARRUSEL DE PROVEEDORES OPTIMIZADO
  Widget _buildProvidersCarousel() {
    if (_providers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_mall_directory_outlined,
              size: 48,
              color: AppColors.neutral400,
            ),
            const SizedBox(height: 8),
            Text(
              'No hay proveedores disponibles',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.neutral600,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          height: 60,
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
                    'Proveedores cercanos',
                    style: AppTypography.h6.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (_selectedPlace != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            ],
          ),
        ),

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

        if (_providers.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _providers.length,
                    (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentProviderIndex == index
                        ? AppColors.primary
                        : AppColors.neutral300,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProviderCard(ProviderModel provider, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      transform: Matrix4.identity()..scale(isActive ? 1.0 : 0.95),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: isActive ? Border.all(color: AppColors.primary, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isActive ? 0.15 : 0.1),
            blurRadius: isActive ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _launchWhatsApp(provider.phone),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.neutral100,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          provider.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.store,
                              color: AppColors.neutral400,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            provider.name,
                            style: AppTypography.h6.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                provider.rating.toString(),
                                style: AppTypography.bodySmall.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(${provider.salesCount} ventas)',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.neutral600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        provider.category,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  provider.description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.neutral700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppColors.neutral600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      provider.distance,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat,
                            size: 14,
                            color: AppColors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Contactar',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Método para lanzar WhatsApp
  void _launchWhatsApp(String phone) async {
    final message = 'Hola, me interesa conocer más sobre sus productos y servicios.';
    final whatsappUri = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching WhatsApp: $e');
      // Mostrar snackbar de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo abrir WhatsApp'),
          backgroundColor: AppColors.error,
          margin: EdgeInsets.only(
            bottom: _isCarouselExpanded ? 240 : 100,
            left: 16,
            right: 16,
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// MODELO DE DATOS PARA PROVEEDORES
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