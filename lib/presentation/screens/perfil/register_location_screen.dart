import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meter_app/presentation/blocs/map/locations_bloc.dart';

import '../../../domain/entities/map/location.dart';

class RegisterLocationScreen extends StatefulWidget {
  const RegisterLocationScreen({super.key});

  @override
  _RegisterLocationScreenState createState() => _RegisterLocationScreenState();
}

class _RegisterLocationScreenState extends State<RegisterLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  LatLng? _pickedLocation;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _addressController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _selectLocation(LatLng location) {
    setState(() {
      _pickedLocation = location;
    });
  }

  void _saveLocation(BuildContext context) {
    if (_formKey.currentState!.validate() && _pickedLocation != null) {
      final location = Location(
        id: '', // Generar ID único
        title: _titleController.text,
        description: _descriptionController.text,
        latitude: _pickedLocation!.latitude,
        longitude: _pickedLocation!.longitude,
        address: _addressController.text,
        userId: '8c04272f-ee99-4965-959c-9cbe3ddf2fc9', // Obtener ID del usuario actual
      );

      BlocProvider.of<LocationsBloc>(context).add(AddNewLocation(location));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete the form and pick a location')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Location'),
      ),
      body: BlocConsumer<LocationsBloc, LocationsState>(
        listener: (context, state) {
          if (state is LocationsLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location saved successfully')),
            );
          } else if (state is LocationsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is LocationsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Address'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 200,
                      child: GoogleMap(
                        initialCameraPosition: const CameraPosition(
                          target: LatLng(-12.0464, -77.0428), // Ubicación inicial en Lima, Perú
                          zoom: 14,
                        ),
                        onTap: _selectLocation,
                        markers: _pickedLocation == null
                            ? {}
                            : {
                          Marker(
                            markerId: const MarkerId('selected-location'),
                            position: _pickedLocation!,
                          ),
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _saveLocation(context),
                      child: const Text('Save Location'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
