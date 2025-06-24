// lib/presentation/screens/perfil/register_location/register_location_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:meter_app/domain/entities/map/location.dart';

import '../../../../config/theme/theme.dart';
import '../../../../config/utils/show_snackbar.dart';
import '../../../../domain/entities/auth/user_profile.dart';
import '../../../blocs/map/locations_bloc.dart';
import '../../../blocs/profile/profile_bloc.dart';

/// Versión mejorada pero compatible del RegisterLocationScreen
/// Mantiene la estructura original pero con mejoras de UX y manejo de errores
class RegisterLocationScreen extends StatefulWidget {
  const RegisterLocationScreen({super.key});

  @override
  _RegisterLocationScreenState createState() => _RegisterLocationScreenState();
}

class _RegisterLocationScreenState extends State<RegisterLocationScreen>
    with TickerProviderStateMixin {

  // ═══════════════════════════════════════════════════════════════════════════
  // CONTROLADORES (Compatible con versión original)
  // ═══════════════════════════════════════════════════════════════════════════

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;

  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();
  final FocusNode _addressFocusNode = FocusNode();

  // ═══════════════════════════════════════════════════════════════════════════
  // ANIMACIONES (Nuevas - mejoran UX)
  // ═══════════════════════════════════════════════════════════════════════════

  late AnimationController _slideAnimationController;
  late AnimationController _fadeAnimationController;
  late AnimationController _mapAnimationController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _mapScaleAnimation;

  // ═══════════════════════════════════════════════════════════════════════════
  // ESTADO (Compatible + mejoras)
  // ═══════════════════════════════════════════════════════════════════════════

  LatLng? _pickedLocation;
  LatLng? _initialLocation;
  File? _selectedImage;
  bool _isLocationLoading = true;
  bool _isAddressLoading = false;
  bool _isSaving = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _determineLocation();
  }

  @override
  void dispose() {
    _disposeControllers();
    _disposeAnimations();
    super.dispose();
  }

  void _initializeControllers() {
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _addressController = TextEditingController();
  }

  void _initializeAnimations() {
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _mapAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeOut,
    ));

    _mapScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mapAnimationController,
      curve: Curves.elasticOut,
    ));

    // Iniciar animaciones
    _fadeAnimationController.forward();
    _slideAnimationController.forward();
  }

  void _disposeControllers() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _addressFocusNode.dispose();
  }

  void _disposeAnimations() {
    _slideAnimationController.dispose();
    _fadeAnimationController.dispose();
    _mapAnimationController.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LÓGICA DE UBICACIÓN (Mejorada pero compatible)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _determineLocation() async {
    setState(() {
      _isLocationLoading = true;
      _locationError = null;
    });

    try {
      final hasPermission = await _handleLocationPermission();
      if (!hasPermission) {
        setState(() {
          _locationError = 'Permisos de ubicación denegados';
          _isLocationLoading = false;
          // Usar ubicación por defecto
          _initialLocation = const LatLng(-12.0464, -77.0428); // Lima, Perú
        });
        _mapAnimationController.forward();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _initialLocation = LatLng(position.latitude, position.longitude);
        _isLocationLoading = false;
      });

      _mapAnimationController.forward();

    } catch (e) {
      setState(() {
        _locationError = 'Error al obtener ubicación: ${e.toString()}';
        _isLocationLoading = false;
        // Usar ubicación por defecto
        _initialLocation = const LatLng(-12.0464, -77.0428);
      });
      _mapAnimationController.forward();
    }
  }

  Future<bool> _handleLocationPermission() async {
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

  void _selectLocation(LatLng location) async {
    setState(() {
      _pickedLocation = location;
      _isAddressLoading = true;
      _addressController.text = 'Buscando dirección...';
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        final addressParts = [
          place.name,
          place.street,
          place.locality,
          place.administrativeArea,
        ].where((part) => part != null && part.isNotEmpty).toList();

        final address = addressParts.isNotEmpty
            ? addressParts.join(', ')
            : 'Ubicación seleccionada';

        setState(() {
          _addressController.text = address;
          _isAddressLoading = false;
        });
      } else {
        setState(() {
          _addressController.text = 'Dirección no encontrada';
          _isAddressLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _addressController.text = 'Error al obtener dirección';
        _isAddressLoading = false;
      });
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LÓGICA DE IMAGEN (Mejorada)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final ImageSource? source = await _showImageSourceDialog();
      if (source == null) return;

      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'Error al seleccionar imagen: ${e.toString()}');
      }
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Seleccionar imagen',
            style: context.textTheme.headlineSmall?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildImageSourceOption(
                icon: Icons.camera_alt,
                title: 'Cámara',
                subtitle: 'Tomar una nueva foto',
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              const SizedBox(height: 8),
              _buildImageSourceOption(
                icon: Icons.photo_library,
                title: 'Galería',
                subtitle: 'Seleccionar de galería',
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: context.colors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // VALIDACIONES (Mejoradas)
  // ═══════════════════════════════════════════════════════════════════════════

  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, ingresa un título';
    }
    if (value.trim().length < 3) {
      return 'El título debe tener al menos 3 caracteres';
    }
    if (value.trim().length > 100) {
      return 'El título no puede exceder 100 caracteres';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, ingresa una descripción';
    }
    if (value.trim().length < 10) {
      return 'La descripción debe tener al menos 10 caracteres';
    }
    if (value.trim().length > 500) {
      return 'La descripción no puede exceder 500 caracteres';
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GUARDAR UBICACIÓN (Compatible con sistema original)
  // ═══════════════════════════════════════════════════════════════════════════

  void _saveLocation(BuildContext context, UserProfile userProfile) async {
    // Unfocus para ocultar teclado
    FocusScope.of(context).unfocus();

    // Validar formulario
    if (!_formKey.currentState!.validate()) {
      showSnackBar(context, 'Por favor, completa todos los campos correctamente');
      return;
    }

    // Validar ubicación seleccionada
    if (_pickedLocation == null) {
      showSnackBar(context, 'Por favor, selecciona una ubicación en el mapa');
      return;
    }

    // Validar imagen seleccionada
    if (_selectedImage == null) {
      showSnackBar(context, 'Por favor, selecciona una imagen');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Usar el sistema original: subir imagen primero
      context.read<LocationsBloc>().add(UploadImageEvent(_selectedImage!));
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      showSnackBar(context, 'Error al guardar: ${e.toString()}');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CONSTRUCCIÓN DE LA UI (Mejorada pero compatible)
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: _buildAppBar(),
      body: BlocListener<LocationsBloc, LocationsState>(
        listener: _handleLocationsBlocListener,
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            if (profileState is ProfileLoading || _isLocationLoading) {
              return _buildLoadingState();
            } else if (profileState is ProfileLoaded) {
              return _buildMainContent(profileState.userProfile);
            }
            return _buildErrorState();
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Registrar Ubicación',
        style: context.textTheme.headlineSmall?.copyWith(
          color: context.colors.surface,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: context.colors.primary,
      foregroundColor: context.colors.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: context.colors.primary),
          const SizedBox(height: 16),
          Text(
            _isLocationLoading ? 'Obteniendo ubicación...' : 'Cargando perfil...',
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: context.colors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar la información',
            style: context.textTheme.headlineSmall?.copyWith(
              color: context.colors.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _locationError ?? 'Por favor, intenta nuevamente',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _determineLocation,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              foregroundColor: context.colors.surface,
            ),
            child: const Text('Intentar nuevamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(UserProfile userProfile) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildFormFields(),
                const SizedBox(height: 24),
                _buildMapSection(),
                const SizedBox(height: 24),
                _buildAddressField(),
                const SizedBox(height: 24),
                _buildImageSection(),
                const SizedBox(height: 32),
                _buildSaveButton(userProfile),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        _buildTextField(
          controller: _titleController,
          focusNode: _titleFocusNode,
          label: 'Título',
          hintText: 'Ingresa el título de la ubicación',
          prefixIcon: Icons.location_on,
          validator: _validateTitle,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _descriptionController,
          focusNode: _descriptionFocusNode,
          label: 'Descripción',
          hintText: 'Describe esta ubicación...',
          prefixIcon: Icons.description,
          validator: _validateDescription,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hintText,
    required IconData prefixIcon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textTheme.titleMedium?.copyWith(
            color: context.colors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          validator: validator,
          maxLines: maxLines,
          style: context.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(prefixIcon, color: context.colors.primary),
            filled: true,
            fillColor: context.colors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.colors.primary.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.colors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.colors.error),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildMapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecciona la ubicación en el mapa',
          style: context.textTheme.titleMedium?.copyWith(
            color: context.colors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ScaleTransition(
          scale: _mapScaleAnimation,
          child: Container(
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _initialLocation != null
                  ? GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _initialLocation!,
                  zoom: 15,
                ),
                onTap: _selectLocation,
                markers: _pickedLocation == null
                    ? {}
                    : {
                  Marker(
                    markerId: const MarkerId('selected-location'),
                    position: _pickedLocation!,
                    infoWindow: const InfoWindow(
                      title: 'Ubicación seleccionada',
                    ),
                  ),
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
                mapToolbarEnabled: false,
                compassEnabled: true,
              )
                  : Container(
                color: context.colors.surface,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off,
                        size: 48,
                        color: context.colors.textSecondary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Mapa no disponible',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_pickedLocation != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: context.colors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: context.colors.success.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: context.colors.success,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ubicación seleccionada: ${_pickedLocation!.latitude.toStringAsFixed(6)}, ${_pickedLocation!.longitude.toStringAsFixed(6)}',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dirección',
          style: context.textTheme.titleMedium?.copyWith(
            color: context.colors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _addressController,
          focusNode: _addressFocusNode,
          enabled: !_isAddressLoading,
          style: context.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Dirección obtenida automáticamente',
            prefixIcon: Icon(Icons.location_city, color: context.colors.primary),
            suffixIcon: _isAddressLoading
                ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.colors.primary,
              ),
            )
                : null,
            filled: true,
            fillColor: context.colors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.colors.primary.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.colors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Imagen de la ubicación',
          style: context.textTheme.titleMedium?.copyWith(
            color: context.colors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: _selectedImage != null ? 200 : 120,
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.colors.primary.withOpacity(0.3),
                width: 2,
                style: BorderStyle.solid,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _selectedImage != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                children: [
                  Image.file(
                    _selectedImage!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedImage = null;
                          });
                        },
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_a_photo,
                  size: 48,
                  color: context.colors.primary.withOpacity(0.7),
                ),
                const SizedBox(height: 8),
                Text(
                  'Toca para seleccionar imagen',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cámara o galería',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(UserProfile userProfile) {
    return ElevatedButton(
      onPressed: _isSaving ? null : () => _saveLocation(context, userProfile),
      style: ElevatedButton.styleFrom(
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.surface,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: _isSaving
          ? Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: context.colors.surface,
            ),
          ),
          const SizedBox(width: 12),
          const Text('Guardando...'),
        ],
      )
          : Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.save),
          const SizedBox(width: 8),
          Text(
            'Guardar Ubicación',
            style: context.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MANEJO DE EVENTOS DEL BLOC (Compatible con sistema original)
  // ═══════════════════════════════════════════════════════════════════════════

  void _handleLocationsBlocListener(BuildContext context, LocationsState state) {
    if (state is ImageUploaded) {
      // Obtener el usuario actual de la sesión
      final profileState = context.read<ProfileBloc>().state;
      if (profileState is ProfileLoaded) {
        final location = LocationMap(
          id: null,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          latitude: _pickedLocation!.latitude,
          longitude: _pickedLocation!.longitude,
          address: _addressController.text.trim(),
          userId: profileState.userProfile.id, // Usuario de la sesión actual
          imageUrl: state.imageUrl,
        );

        // Usar el sistema original de LocationsBloc
        context.read<LocationsBloc>().add(AddNewLocation(location));
      } else {
        setState(() {
          _isSaving = false;
        });
        showSnackBar(context, 'Error: Usuario no autenticado');
      }
    } else if (state is LocationSaved) {
      setState(() {
        _isSaving = false;
      });
      showSnackBar(context, 'Ubicación guardada exitosamente');

      // Refrescar la lista de ubicaciones para que aparezca en OptimizedMapScreen
      context.read<LocationsBloc>().add(LoadLocations());

      Navigator.of(context).pop();
    } else if (state is LocationsError) {
      setState(() {
        _isSaving = false;
      });
      showSnackBar(context, 'Error: ${state.message}');
    }
  }
}