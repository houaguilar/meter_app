import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meter_app/config/constants/colors.dart';
import 'package:meter_app/presentation/blocs/map/place/place_bloc.dart';
import 'package:meter_app/presentation/screens/mapa/widgets/providers_list.dart';
import 'package:meter_app/presentation/styles/button_styles.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../domain/entities/map/location.dart';
import '../../blocs/map/locations_bloc.dart';
import '../../widgets/widgets.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;

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
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
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
            onPressed: () => context.pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              context.pop();
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
      appBar: AppBarWidget(titleAppBar: 'Proveedores',),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                BlocBuilder<LocationsBloc, LocationsState>(
                  builder: (context, state) {
                    if (state is LocationsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is LocationsLoaded) {
                      Set<Marker> markers = _buildMarkers(state.locations);

                      if (_currentPosition != null) {
                        markers.add(
                          Marker(
                            markerId: const MarkerId('current_location'),
                            position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                          ),
                        );
                      }

                      return GoogleMap(
                        onMapCreated: (controller) => _mapController = controller,
                        initialCameraPosition: _getInitialCameraPosition(),
                        markers: markers,
                      );
                    } else {
                      return const Center(child: Text('No hay ubicaciones disponibles'));
                    }
                  },
                ),
                BlocListener<PlaceBloc, PlaceState>(
                  listener: (context, placeState) {
                    if (placeState is PlaceSelected) {
                      _updateMapPosition(placeState.place.lat, placeState.place.lng);
                    }
                  },
                  child: Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: _buildSearchBar(context),  // Barra de búsqueda
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildProviderList(context),  // Lista de proveedores
        ],
      ),
    );
  }

  // Construcción de los marcadores de Google Maps
  Set<Marker> _buildMarkers(List<LocationMap> locations) {
    return locations.map((location) {
      return Marker(
        markerId: MarkerId(location.id ?? ''),
        position: LatLng(location.latitude, location.longitude),
        infoWindow: InfoWindow(
          title: location.title,
          snippet: location.description,
          onTap: () => _showLocationDetails(location),
        ),
      );
    }).toSet();
  }

  // Función para mover la cámara a la nueva posición seleccionada
  void _updateMapPosition(double lat, double lng) {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(lat, lng),
        ),
      );
    }
  }

  // Posición inicial de la cámara
  CameraPosition _getInitialCameraPosition() {
    return _currentPosition != null
        ? CameraPosition(
      target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      zoom: 14,
    )
        : const CameraPosition(target: LatLng(0, 0), zoom: 14);
  }

  // Barra de búsqueda que usa el nuevo PlaceBloc
  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      readOnly: true,
      onTap: () => context.pushNamed('search'),
      decoration: InputDecoration(
        hintText: "Buscar dirección...",
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  // Lista de proveedores
  Widget _buildProviderList(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Proveedores Recomendados',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: AppColors.primaryMetraShop,
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: ProvidersList(),
          ),
        ],
      ),
    );
  }

  void _showLocationDetail(LocationMap location) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return LocationDetailsSheet(location: location);
      },
    );
  }


  void _showLocationDetails(LocationMap location) {
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
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: location.imageUrl != null
                       ? NetworkImage(location.imageUrl!)
                        : null,
                    child: location.imageUrl == null
                        ? const Icon(Icons.person, size: 40)
                        : const Icon(Icons.person, size: 40),
                  ),
                 // Image.asset('assets/images/ferreteria.png', width: 200, height: 200,),
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


/*
class ProvidersList extends StatelessWidget {
  const ProvidersList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 1, // Cambiar según la cantidad de proveedores
      itemBuilder: (context, index) {
        return const ProviderCard();
      },
    );
  }
}

class ProviderCard extends StatelessWidget {
  const ProviderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: const Icon(Icons.store),
        title: const Text('Promart', style: TextStyle(fontWeight: FontWeight.bold),),
        subtitle: const Text(
          'Calle Mercaderes 920, Santiago de Surco\nTeléfono: 987654321',
          style: TextStyle(fontSize: 8,),
        ),
        trailing: ElevatedButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (_) => const ContactBottomSheet(),
            );
          },
          child: const Text('Contactar', style: TextStyle(fontSize: 10),),
        ),
      ),
    );
  }
}
*/

class ContactBottomSheet extends StatelessWidget {
  const ContactBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Contactar',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            style: CustomButtonStyles.outlinedCardStyle,
            onPressed: () {
              // Lógica para contactar por teléfono
            },
            child: const Text('Contactar por Teléfono'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            style: CustomButtonStyles.outlinedCardStyle,
            onPressed: () {
              // Lógica para contactar por WhatsApp
            },
            child: const Text('Contactar por WhatsApp'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class LocationDetailsSheet extends StatelessWidget {
  final LocationMap location;

  const LocationDetailsSheet({
    super.key,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLocationHeader(context),
          const SizedBox(height: 16),
          _buildLocationDetails(context),
          const SizedBox(height: 16),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildLocationHeader(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/images/ferreteria.png', // Imagen de la ferretería o proveedor
          width: 100,
          height: 100,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                location.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(location.description),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dirección:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(location.address),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () => _launchWhatsApp('location.phone'),
          icon: const Icon(Icons.message),
          label: const Text('WhatsApp'),
        ),
        ElevatedButton.icon(
          onPressed: () => _launchPhoneCall('location.phone'),
          icon: const Icon(Icons.phone),
          label: const Text('Llamar'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            // Aquí puedes implementar más acciones si es necesario
          },
          icon: const Icon(Icons.info),
          label: const Text('Más Info'),
        ),
      ],
    );
  }

  Future<void> _launchWhatsApp(String phone) async {
    final whatsappUrl = 'https://wa.me/$phone?text=Hola';
    if (await canLaunch(whatsappUrl)) {
      await launch(whatsappUrl);
    } else {
      throw 'No se pudo abrir WhatsApp para $phone';
    }
  }

  Future<void> _launchPhoneCall(String phone) async {
    final phoneUrl = 'tel:$phone';
    if (await canLaunch(phoneUrl)) {
      await launch(phoneUrl);
    } else {
      throw 'No se pudo realizar la llamada a $phone';
    }
  }
}
