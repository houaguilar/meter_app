import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:meter_app/domain/entities/map/location.dart';

import '../../../../config/theme/theme.dart';
import '../../../../config/utils/show_snackbar.dart';
import '../../../../config/utils/validators.dart';
import '../../../../domain/entities/auth/user_profile.dart';
import '../../../../domain/entities/map/document_type.dart';
import '../../../../domain/entities/map/verification_status.dart';
import '../../../blocs/map/locations_bloc.dart';
import '../../../blocs/profile/profile_bloc.dart';

class RegisterLocationScreen extends StatefulWidget {
  const RegisterLocationScreen({super.key});

  @override
  State<RegisterLocationScreen> createState() => _RegisterLocationScreenState();
}

class _RegisterLocationScreenState extends State<RegisterLocationScreen>
    with TickerProviderStateMixin {

  // ═══════════════════════════════════════════════════════════════════════════
  // CONTROLADORES Y FOCUS NODES
  // ═══════════════════════════════════════════════════════════════════════════

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _documentController;
  late TextEditingController _phoneController;
  late TextEditingController _whatsappController;

  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();
  final FocusNode _addressFocusNode = FocusNode();
  final FocusNode _documentFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _whatsappFocusNode = FocusNode();

  // ═══════════════════════════════════════════════════════════════════════════
  // CONTROLADOR DE GOOGLE MAPS (Solucionando problema de movimiento)
  // ═══════════════════════════════════════════════════════════════════════════

  GoogleMapController? _mapController;

  // ═══════════════════════════════════════════════════════════════════════════
  // ANIMACIONES
  // ═══════════════════════════════════════════════════════════════════════════

  late AnimationController _slideAnimationController;
  late AnimationController _fadeAnimationController;
  late AnimationController _mapAnimationController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _mapScaleAnimation;

  // ═══════════════════════════════════════════════════════════════════════════
  // ESTADO
  // ═══════════════════════════════════════════════════════════════════════════

  LatLng? _pickedLocation;
  LatLng? _initialLocation;
  File? _selectedImage;
  bool _isLocationLoading = true;
  bool _isAddressLoading = false;
  bool _isSaving = false;
  String? _locationError;

  // Estado para campos de marketplace
  DocumentType _selectedDocumentType = DocumentType.dni;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // ═══════════════════════════════════════════════════════════════════════════
  // CONFIGURACIÓN INICIAL
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _getCurrentLocation();
  }

  void _initializeControllers() {
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _addressController = TextEditingController();
    _documentController = TextEditingController();
    _phoneController = TextEditingController();
    _whatsappController = TextEditingController();
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
      begin: const Offset(0, 0.1),
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
      curve: Curves.easeIn,
    ));

    _mapScaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mapAnimationController,
      curve: Curves.elasticOut,
    ));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // OBTENER UBICACIÓN ACTUAL
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError = 'Los servicios de ubicación están deshabilitados';
          _isLocationLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationError = 'Permisos de ubicación denegados';
            _isLocationLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError = 'Permisos de ubicación denegados permanentemente';
          _isLocationLoading = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _initialLocation = LatLng(position.latitude, position.longitude);
        _pickedLocation = _initialLocation;
        _isLocationLoading = false;
      });

      await _getAddressFromLatLng(_initialLocation!);
      _startAnimations();

    } catch (e) {
      setState(() {
        _locationError = 'Error al obtener ubicación: ${e.toString()}';
        _isLocationLoading = false;
      });
    }
  }

  void _startAnimations() {
    _fadeAnimationController.forward();
    _slideAnimationController.forward();
    _mapAnimationController.forward();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SELECCIÓN DE UBICACIÓN EN EL MAPA
  // ═══════════════════════════════════════════════════════════════════════════

  void _selectLocation(LatLng position) {
    setState(() {
      _pickedLocation = position;
    });
    _getAddressFromLatLng(position);
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    setState(() {
      _isAddressLoading = true;
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
          _addressController.text = address;
          _isAddressLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _addressController.text = 'Dirección no disponible';
        _isAddressLoading = false;
      });
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SELECCIÓN DE IMAGEN
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      showSnackBar(context, 'Error al seleccionar imagen: ${e.toString()}');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GUARDAR UBICACIÓN (Solucionando problema de ID y flujo)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _saveLocation(BuildContext context, UserProfile userProfile) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_pickedLocation == null) {
      showSnackBar(context, 'Por favor, selecciona una ubicación en el mapa');
      return;
    }

    if (_selectedImage == null) {
      showSnackBar(context, 'Por favor, selecciona una imagen');
      return;
    }

    // Validar fecha y hora de verificación
    if (_selectedDate == null) {
      showSnackBar(context, 'Por favor, selecciona una fecha de verificación');
      return;
    }

    if (_selectedTime == null) {
      showSnackBar(context, 'Por favor, selecciona una hora de verificación');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // 1. Primero subir la imagen
      context.read<LocationsBloc>().add(UploadImageEvent(_selectedImage!));
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      showSnackBar(context, 'Error al iniciar el guardado: ${e.toString()}');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // VALIDADORES
  // ═══════════════════════════════════════════════════════════════════════════

  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El título es obligatorio';
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
      return 'La descripción es obligatoria';
    }
    if (value.trim().length < 10) {
      return 'La descripción debe tener al menos 10 caracteres';
    }
    if (value.trim().length > 500) {
      return 'La descripción no puede exceder 500 caracteres';
    }
    return null;
  }

  String? _validateDocument(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El documento es obligatorio';
    }

    if (_selectedDocumentType == DocumentType.dni) {
      final result = Validators.validateDNI(value);
      return result.isValid ? null : result.message;
    } else {
      final result = Validators.validateCE(value);
      return result.isValid ? null : result.message;
    }
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El teléfono es obligatorio';
    }
    final result = Validators.validatePhonePeru(value);
    return result.isValid ? null : result.message;
  }

  String? _validateWhatsApp(String? value) {
    // WhatsApp es opcional
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final result = Validators.validatePhonePeru(value);
    return result.isValid ? null : result.message;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LIMPIEZA DE RECURSOS
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _documentController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _addressFocusNode.dispose();
    _documentFocusNode.dispose();
    _phoneFocusNode.dispose();
    _whatsappFocusNode.dispose();
    _slideAnimationController.dispose();
    _fadeAnimationController.dispose();
    _mapAnimationController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CONSTRUCCIÓN DE LA UI
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
        style: context.textTheme.displaySmall?.copyWith(
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
            style: context.textTheme.displaySmall?.copyWith(
              color: context.colors.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _locationError ?? 'Error desconocido',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isLocationLoading = true;
                _locationError = null;
              });
              _getCurrentLocation();
            },
            child: const Text('Reintentar'),
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
                _buildImageSection(),
                const SizedBox(height: 32),
                _buildSaveButton(userProfile),
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
        _buildInputField(
          label: 'Título de la ubicación',
          hintText: 'Ej: Mi oficina, Casa de campo...',
          controller: _titleController,
          focusNode: _titleFocusNode,
          prefixIcon: Icons.location_on,
          validator: _validateTitle,
        ),
        const SizedBox(height: 20),
        _buildInputField(
          label: 'Descripción',
          hintText: 'Describe esta ubicación...',
          controller: _descriptionController,
          focusNode: _descriptionFocusNode,
          prefixIcon: Icons.description,
          validator: _validateDescription,
          maxLines: 3,
        ),
        const SizedBox(height: 20),
        _buildInputField(
          label: 'Dirección',
          hintText: _isAddressLoading ? 'Obteniendo dirección...' : 'Dirección automática',
          controller: _addressController,
          focusNode: _addressFocusNode,
          prefixIcon: Icons.place,
          validator: null,
        ),
        const SizedBox(height: 24),
        _buildMarketplaceSectionHeader(),
        const SizedBox(height: 16),
        _buildDocumentTypeSelector(),
        const SizedBox(height: 20),
        _buildInputField(
          label: 'Número de Documento',
          hintText: _selectedDocumentType == DocumentType.dni ? 'Ej: 12345678' : 'Ej: 001234567',
          controller: _documentController,
          focusNode: _documentFocusNode,
          prefixIcon: Icons.credit_card,
          validator: _validateDocument,
        ),
        const SizedBox(height: 20),
        _buildInputField(
          label: 'Teléfono',
          hintText: 'Ej: 987654321',
          controller: _phoneController,
          focusNode: _phoneFocusNode,
          prefixIcon: Icons.phone,
          validator: _validatePhone,
        ),
        const SizedBox(height: 20),
        _buildInputField(
          label: 'WhatsApp (Opcional)',
          hintText: 'Ej: 987654321',
          controller: _whatsappController,
          focusNode: _whatsappFocusNode,
          prefixIcon: Icons.chat,
          validator: _validateWhatsApp,
        ),
        const SizedBox(height: 20),
        _buildVerificationDateTimeSection(),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required FocusNode focusNode,
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

  Widget _buildMarketplaceSectionHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.store,
            color: context.colors.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Información de Proveedor',
                  style: context.textTheme.titleMedium?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Complete los datos para registrarse como proveedor',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Documento',
          style: context.textTheme.titleMedium?.copyWith(
            color: context.colors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDocumentTypeOption(
                DocumentType.dni,
                'DNI',
                'Documento Nacional de Identidad',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDocumentTypeOption(
                DocumentType.ce,
                'CE',
                'Carné de Extranjería',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDocumentTypeOption(
    DocumentType type,
    String title,
    String subtitle,
  ) {
    final isSelected = _selectedDocumentType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDocumentType = type;
          _documentController.clear();
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.primary.withOpacity(0.1)
              : context.colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? context.colors.primary
                : context.colors.primary.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: isSelected
                        ? context.colors.primary
                        : context.colors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isSelected
                      ? context.colors.primary
                      : context.colors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.textSecondary,
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationDateTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fecha y Hora de Verificación',
          style: context.textTheme.titleMedium?.copyWith(
            color: context.colors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Seleccione cuándo desea que verifiquemos su ubicación',
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDateSelector(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTimeSelector(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();
        final firstDate = now.add(const Duration(days: 1)); // Mínimo mañana
        final lastDate = now.add(const Duration(days: 30)); // Máximo 30 días

        final pickedDate = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? firstDate,
          firstDate: firstDate,
          lastDate: lastDate,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: context.colors.primary,
                  onPrimary: context.colors.surface,
                  surface: context.colors.surface,
                  onSurface: context.colors.textPrimary,
                ),
              ),
              child: child!,
            );
          },
        );

        if (pickedDate != null) {
          setState(() {
            _selectedDate = pickedDate;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedDate != null
                ? context.colors.primary
                : context.colors.primary.withOpacity(0.3),
            width: _selectedDate != null ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: _selectedDate != null
                  ? context.colors.primary
                  : context.colors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedDate != null
                    ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                    : 'Seleccionar fecha',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: _selectedDate != null
                      ? context.colors.textPrimary
                      : context.colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    return GestureDetector(
      onTap: () async {
        final pickedTime = await showTimePicker(
          context: context,
          initialTime: _selectedTime ?? const TimeOfDay(hour: 9, minute: 0),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: context.colors.primary,
                  onPrimary: context.colors.surface,
                  surface: context.colors.surface,
                  onSurface: context.colors.textPrimary,
                ),
              ),
              child: child!,
            );
          },
        );

        if (pickedTime != null) {
          setState(() {
            _selectedTime = pickedTime;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedTime != null
                ? context.colors.primary
                : context.colors.primary.withOpacity(0.3),
            width: _selectedTime != null ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              color: _selectedTime != null
                  ? context.colors.primary
                  : context.colors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedTime != null
                    ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                    : 'Seleccionar hora',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: _selectedTime != null
                      ? context.colors.textPrimary
                      : context.colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
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
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
                onTap: _selectLocation,
                // CONFIGURACIÓN CRUCIAL PARA PERMITIR MOVIMIENTO DEL MAPA
                zoomControlsEnabled: false,
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                mapType: MapType.normal,
                gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
                markers: _pickedLocation == null
                    ? <Marker>{}
                    : {
                  Marker(
                    markerId: const MarkerId('picked-location'),
                    position: _pickedLocation!,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue,
                    ),
                    infoWindow: const InfoWindow(
                      title: 'Ubicación seleccionada',
                    ),
                  ),
                },
              )
                  : Container(
                color: Colors.grey[300],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
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
          'Agregar imagen',
          style: context.textTheme.titleMedium?.copyWith(
            color: context.colors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.colors.primary.withOpacity(0.3),
                width: 2,
                style: BorderStyle.solid,
              ),
              color: context.colors.surface,
            ),
            child: _selectedImage != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.file(
                _selectedImage!,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt,
                  size: 48,
                  color: context.colors.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  'Toca para tomar una foto',
                  style: context.textTheme.bodyLarge?.copyWith(
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
      onPressed: (_isSaving || _pickedLocation == null)
          ? null
          : () => _saveLocation(context, userProfile),
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
  // MANEJO DE EVENTOS DEL BLOC (Corregido para manejar ID)
  // ═══════════════════════════════════════════════════════════════════════════

  void _handleLocationsBlocListener(BuildContext context, LocationsState state) {
    if (state is ImageUploaded) {
      // Obtener el usuario actual de la sesión
      final profileState = context.read<ProfileBloc>().state;
      if (profileState is ProfileLoaded) {
        // Combinar fecha y hora para scheduledDateTime
        final scheduledDateTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );

        // Limpiar números de teléfono
        final cleanedPhone = Validators.cleanPhone(_phoneController.text);
        final cleanedWhatsApp = _whatsappController.text.isNotEmpty
            ? Validators.cleanPhone(_whatsappController.text)
            : null;

        // Crear ubicación con todos los campos de marketplace
        final location = LocationMap(
          id: null, // Supabase generará el ID automáticamente
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          latitude: _pickedLocation!.latitude,
          longitude: _pickedLocation!.longitude,
          address: _addressController.text.trim(),
          userId: profileState.userProfile.id,
          imageUrl: state.imageUrl,
          // Campos de marketplace
          document: _documentController.text.trim(),
          documentType: _selectedDocumentType,
          phone: cleanedPhone,
          whatsapp: cleanedWhatsApp,
          verificationStatus: VerificationStatus.pendingApproval,
          scheduledDate: scheduledDateTime,
          scheduledTime: '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
        );

        // Guardar la ubicación con la imagen ya subida
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
      showSnackBar(context, 'Ubicación registrada. Pendiente de aprobación.');

      // Refrescar la lista de ubicaciones
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