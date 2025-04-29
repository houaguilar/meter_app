import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:meter_app/domain/entities/map/location.dart';
import 'package:uuid/uuid.dart';

import '../../../../config/utils/show_snackbar.dart';
import '../../../../domain/entities/auth/user_profile.dart';
import '../../../blocs/map/locations_bloc.dart';
import '../../../blocs/profile/profile_bloc.dart';


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
  LatLng? _initialLocation;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _addressController = TextEditingController();
    _determineLocation();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _determineLocation() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _initialLocation = LatLng(position.latitude, position.longitude);
    });
  }

  Future<bool> _handleLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final requested = await Geolocator.requestPermission();
      if (requested == LocationPermission.deniedForever) {
        showSnackBar(context, 'Location permissions are permanently denied.');
        return false;
      } else if (requested == LocationPermission.denied) {
        showSnackBar(context, 'Location permissions are denied.');
        return false;
      }
    }
    return true;
  }

  void _selectLocation(LatLng location) async {
    setState(() {
      _pickedLocation = location;
      _addressController.text = 'Searching...';
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        final address =
            '${place.name}';

        setState(() {
          _addressController.text = address;
        });
      } else {
        setState(() {
          _addressController.text = 'No address found';
        });
      }
    } catch (e) {
      setState(() {
        _addressController.text = 'Error retrieving address';
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    } else {
      showSnackBar(context, 'No image selected');
    }
  }

  void _saveLocation(BuildContext context, UserProfile userProfile) async {
    if (_formKey.currentState!.validate() && _pickedLocation != null && _selectedImage != null) {
      BlocProvider.of<LocationsBloc>(context).add(
        UploadImageEvent(_selectedImage!),
      );
    } else {
      showSnackBar(context, 'Complete all fields and pick a location');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Location')),
      body: BlocListener<LocationsBloc, LocationsState>(
        listener: (context, state) {
          if (state is ImageUploaded) {
            final userProfile = context.read<ProfileBloc>().state as ProfileLoaded;
            final location = LocationMap(
              id: null,
              title: _titleController.text,
              description: _descriptionController.text,
              latitude: _pickedLocation!.latitude.toDouble(),
              longitude: _pickedLocation!.longitude.toDouble(),
              address: _addressController.text,
              userId: userProfile.userProfile.id,
              imageUrl: state.imageUrl,
            );
            BlocProvider.of<LocationsBloc>(context).add(AddNewLocation(location));
          } else if (state is LocationSaved) {
            showSnackBar(context, 'Location saved successfully');
            Navigator.of(context).pop();
          } else if (state is LocationsError) {
            showSnackBar(context, state.message);
          }
        },
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            if (profileState is ProfileLoading || _initialLocation == null) {
              return const Center(child: CircularProgressIndicator());
            } else if (profileState is ProfileLoaded) {
              return _buildForm(context, profileState.userProfile);
            }
            return const Center(child: Text('Error loading profile or location'));
          },
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, UserProfile userProfile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) =>
              value == null || value.isEmpty ? 'Please enter a title' : null,
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (value) =>
              value == null || value.isEmpty ? 'Please enter a description' : null,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _initialLocation ?? const LatLng(0, 0),
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
            const SizedBox(height: 10),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Image'),
            ),
            if (_selectedImage != null)
              Image.file(
                _selectedImage!,
                height: 150,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _saveLocation(context, userProfile),
              child: const Text('Save Location'),
            ),
          ],
        ),
      ),
    );
  }
}
