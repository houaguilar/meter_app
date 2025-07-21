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
import '../../assets/images.dart';
import '../../blocs/map/locations_bloc.dart';
import '../../blocs/map/place/place_bloc.dart';
import '../../widgets/app_bar/app_bar_widget.dart';
import 'detail/location_detail_hardcoded_screen.dart';
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

  // Lista de proveedores simulada (reemplazar con tu fuente de datos real)
  List<ProviderModel> _providers = [];
  int _currentProviderIndex = 0;

  // Configuración del mapa
  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(-12.046374, -77.042793), // Lima, Perú
    zoom: 12.0,
  );

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController(viewportFraction: 0.85);
    _initializeLocation();
    _loadProviders(); // Cargar proveedores
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
            bottom: 310,
            right: 16,
            child: _buildEnhancedLocationFAB(),
          ),

          // Carrusel de proveedores (SIN expandir/colapsar)
          Positioned(
            bottom: 15,
            left: 0,
            right: 0,
            child: _buildProvidersCarousel(),
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
        await _animateToPosition(position);
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
          markerId: MarkerId(location.id ?? ''),
          position: LatLng(location.latitude, location.longitude),
          infoWindow: InfoWindow(
            title: location.title,
            snippet: location.description,
          ),
          onTap: () => _navigateToLocationDetail(location),
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
        builder: (context) => LocationDetailHardcodedScreen(
          locationId: location.id ?? '1', // Default ID si no tiene
        ),
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
    }
  }

  // BOTTOM SHEET DE UBICACIÓN
  void _showLocationBottomSheet(LocationMap location) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildLocationBottomSheet(location),
    );
  }

  Widget _buildLocationBottomSheet(LocationMap location) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle superior
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.neutral300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Contenido
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.title,
                  style: AppTypography.h3.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppColors.neutral500,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.neutral500,
                        ),
                      ),
                    ),
                  ],
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

  // CARRUSEL DE PROVEEDORES OPTIMIZADO PARA TODOS LOS TAMAÑOS DE PANTALLA
  Widget _buildProvidersCarousel() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;

        // Calculamos la altura del carrusel basada en el tamaño de pantalla
        double carouselHeight;

        if (screenHeight <= 667) {
          // iPhone SE, iPhone 8 y pantallas pequeñas
          carouselHeight = 270;
        } else if (screenHeight <= 736) {
          // iPhone 8 Plus
          carouselHeight = 270;
        } else if (screenHeight <= 812) {
          // iPhone X, iPhone 11 Pro
          carouselHeight = 280;
        } else {
          // Pantallas más grandes
          carouselHeight = 280;
        }

        return Container(
          height: carouselHeight,
          color: Colors.transparent,
          child: _buildCarouselContent(),
        );
      },
    );
  }

  Widget _buildCarouselContent() {
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

    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentProviderIndex = index;
        });
      },
      itemCount: _providers.length,
      itemBuilder: (context, index) {
        final provider = _providers[index];
        final screenWidth = MediaQuery.of(context).size.width;

        // Márgenes adaptativos basados en el ancho de pantalla
        double horizontalMargin;
        if (screenWidth <= 375) {
          horizontalMargin = 12; // Pantallas muy pequeñas
        } else if (screenWidth <= 414) {
          horizontalMargin = 16; // Pantallas medianas
        } else {
          horizontalMargin = 20; // Pantallas grandes
        }

        return GestureDetector(
          onTap: () => _navigateToProviderDetail(provider), // Cambio aquí
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: horizontalMargin,
              vertical: 8,
            ),
            child: _buildProviderCard(_providers[index]),
          ),
        );
      },
    );
  }

  Widget _buildImage(String imageUrl) {
    // Si la URL empieza con http/https, es una imagen de red
    if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppColors.neutral100,
            child: const Icon(
              Icons.image_not_supported,
              size: 48,
              color: AppColors.neutral400,
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: AppColors.neutral100,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          );
        },
      );
    } else {
      // Es un asset local
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppColors.neutral100,
            child: const Icon(
              Icons.image_not_supported,
              size: 48,
              color: AppColors.neutral400,
            ),
          );
        },
      );
    }
  }

  // TARJETA DE PROVEEDOR OPTIMIZADA PARA TODOS LOS TAMAÑOS DE PANTALLA
  Widget _buildProviderCard(ProviderModel provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculamos las dimensiones basadas en el tamaño disponible
        final cardHeight = constraints.maxHeight;
        final cardWidth = constraints.maxWidth;

        // Altura dinámica para la imagen basada en el tamaño de la tarjeta
        final imageHeight = (cardHeight * 0.30).clamp(120.0, 160.0);

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // IMAGEN DEL PROVEEDOR CON ALTURA FIJA RESPONSIVA
              Container(
                height: imageHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Imagen principal
                      _buildImage(provider.imageUrl)
                    ],
                  ),
                ),
              ),

              // INFORMACIÓN DEL PROVEEDOR - USANDO ESPACIO RESTANTE
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fila superior: Rating y ventas
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${provider.rating}',
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${provider.salesCount}',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Nombre del proveedor
                      Flexible(
                        child: Text(
                          provider.name,
                          style: AppTypography.h3.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Descripción del proveedor
                      Flexible(
                        child: Text(
                          provider.description,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.neutral600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Información adicional
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: AppColors.neutral500,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${provider.distance.toStringAsFixed(1)} km',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.neutral500,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppColors.neutral500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            provider.isOpen ? 'Abierto' : 'Cerrado',
                            style: AppTypography.bodySmall.copyWith(
                              color: provider.isOpen
                                  ? AppColors.success
                                  : AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToProviderDetail(ProviderModel provider) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LocationDetailHardcodedScreen(
          locationId: provider.id, // Usa el ID del proveedor
        ),
      ),
    );
  }

  // CARGAR PROVEEDORES (simulado - reemplazar con tu lógica real)
  void _loadProviders() {
    // Datos simulados - reemplazar con tu fuente de datos real
    setState(() {
      _providers = [
        ProviderModel(
          id: '1',
          name: 'Ferretería Central',
          description: 'Materiales de construcción y herramientas',
          category: 'Ferretería',
          imageUrl: AppImages.expressImg,
          rating: 4.8,
          salesCount: 1250,
          distance: 0.8,
          isOpen: true,
        ),
        ProviderModel(
          id: '2',
          name: 'Cemento & Agregados SAC',
          description: 'Venta de cemento, arena, piedra y agregados',
          category: 'Cemento',
          imageUrl: AppImages.equipImg,
          rating: 4.6,
          salesCount: 890,
          distance: 1.2,
          isOpen: false,
        ),
        // Agregar más proveedores según necesites
      ];
    });
  }
}

// Modelo de proveedor (agregar a tu archivo de modelos)
class ProviderModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String imageUrl;
  final double rating;
  final int salesCount;
  final double distance;
  final bool isOpen;

  ProviderModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.rating,
    required this.salesCount,
    required this.distance,
    required this.isOpen,
  });
}