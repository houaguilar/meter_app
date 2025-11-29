import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meter_app/presentation/blocs/profile/profile_bloc.dart';
import 'package:meter_app/presentation/widgets/location/multi_country_location_picker.dart';
import '../../../../config/theme/theme.dart';
import '../../../widgets/dialogs/confirmation_dialog_perfil.dart';

class ImprovedProfileInformationTab extends StatefulWidget {
  const ImprovedProfileInformationTab({super.key});

  @override
  State<ImprovedProfileInformationTab> createState() => _ImprovedProfileInformationTabState();
}

class _ImprovedProfileInformationTabState extends State<ImprovedProfileInformationTab> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _employmentController;
  late TextEditingController _districtController;
  late TextEditingController _customOccupationController;

  // Controllers para el nuevo widget de ubicación (mantienen la misma función)
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  final List<String> _occupations = [
    'Seleccione una ocupación',
    'Arquitecto',
    'Ingeniero Civil',
    'Operario',
    'Maestro de Obra',
    'Técnico en Construcción',
    'Otro'
  ];

  bool _formChanged = false;
  bool _isLoading = false;
  bool _showCustomOccupationField = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupListeners();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshControllersFromBlocState();
  }

  void _refreshControllersFromBlocState() {
    final state = context.read<ProfileBloc>().state;
    if (state is ProfileLoaded) {
      _populateControllers(state.userProfile);
    }
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _employmentController = TextEditingController();
    _districtController = TextEditingController();
    _customOccupationController = TextEditingController();

    final state = context.read<ProfileBloc>().state;
    if (state is ProfileLoaded) {
      _populateControllers(state.userProfile);
    }
  }

  void _populateControllers(dynamic profile) {
    if (_nameController.text != (profile.name ?? '')) {
      _nameController.text = profile.name ?? '';
    }
    if (_phoneController.text != (profile.phone ?? '')) {
      _phoneController.text = profile.phone ?? '';
    }

    // Manejar ocupación: si no está en la lista, es personalizada
    final employment = profile.employment ?? '';
    if (employment.isNotEmpty && !_occupations.contains(employment)) {
      // Es una ocupación personalizada
      _employmentController.text = 'Otro';
      _customOccupationController.text = employment;
      _showCustomOccupationField = true;
    } else {
      _employmentController.text = employment;
      _customOccupationController.text = '';
      _showCustomOccupationField = false;
    }

    if (_districtController.text != (profile.district ?? '')) {
      _districtController.text = profile.district ?? '';
    }
    if (_countryController.text != (profile.nationality ?? '')) {
      _countryController.text = profile.nationality ?? '';
    }
    if (_stateController.text != (profile.province ?? '')) {
      _stateController.text = profile.province ?? '';
    }
    if (_cityController.text != (profile.city ?? '')) {
      _cityController.text = profile.city ?? '';
    }
  }

  void _setupListeners() {
    _nameController.addListener(_onFormChanged);
    _phoneController.addListener(_onFormChanged);
    _employmentController.addListener(_onFormChanged);
    _customOccupationController.addListener(_onFormChanged);
    _districtController.addListener(_onFormChanged);
    _countryController.addListener(_onFormChanged);
    _stateController.addListener(_onFormChanged);
    _cityController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    if (!_formChanged && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _formChanged = true;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    _nameController.dispose();
    _phoneController.dispose();
    _employmentController.dispose();
    _customOccupationController.dispose();
    _districtController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _cityController.dispose();
  }

  void _saveChanges() {
    // Validar el formulario si hay ocupación personalizada
    if (_showCustomOccupationField && !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final profileBloc = context.read<ProfileBloc>();

    // Determinar el valor de employment
    String? employmentValue;
    if (_employmentController.text.trim().isNotEmpty &&
        _employmentController.text.trim() != 'Seleccione una ocupación') {
      // Si seleccionó "Otro", usar el valor del campo personalizado
      if (_employmentController.text.trim() == 'Otro' && _customOccupationController.text.trim().isNotEmpty) {
        employmentValue = _customOccupationController.text.trim();
      } else if (_employmentController.text.trim() != 'Otro') {
        employmentValue = _employmentController.text.trim();
      }
    }

    profileBloc.add(UpdateProfile(
      name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : null,
      phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
      employment: employmentValue,
      nationality: _countryController.text.trim().isNotEmpty ? _countryController.text.trim() : null,
      province: _stateController.text.trim().isNotEmpty ? _stateController.text.trim() : null,
      city: _cityController.text.trim().isNotEmpty ? _cityController.text.trim() : null,
      district: _districtController.text.trim().isNotEmpty ? _districtController.text.trim() : null,
    ));

    profileBloc.add( SubmitProfile());

    setState(() {
      _isLoading = false;
      _formChanged = false;
    });
  }

  void _discardChanges() {
    final state = context.read<ProfileBloc>().state;
    if (state is ProfileLoaded) {
      _populateControllers(state.userProfile);
      setState(() {
        _formChanged = false;
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (!_formChanged) return true;

    final shouldPop = await ConfirmationDialog.show(
      context: context,
      title: '¿Salir sin guardar?',
      content: 'Tienes cambios sin guardar. ¿Estás seguro de que quieres salir?',
      confirmText: 'Salir sin guardar',
      cancelText: 'Cancelar',
      isDestructive: true,
    );

    return shouldPop ?? false;
  }
  // =====================================================================

  @override
  Widget build(BuildContext context) {
    // =============== MANTENER: WillPopScope para confirmación ===============
    return WillPopScope(
      onWillPop: _onWillPop,
      child: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            _populateControllers(state.userProfile);
          }
          // =============== AGREGAR: Listener para ProfileSuccess ===============
          if (state is ProfileSuccess) {
            _showSuccessDialog();
          }
          // =============== AGREGAR: Listener para ProfileError ===============
          if (state is ProfileError) {
            _showErrorDialog(state.message);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    'Información Personal',
                    'Completa tu perfil para una mejor experiencia',
                    Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 24),
                  _buildPersonalInfoSection(),
                  const SizedBox(height: 32),
                  _buildSectionHeader(
                    'Información Profesional',
                    'Detalles sobre tu actividad laboral',
                    Icons.work_outline_rounded,
                  ),
                  const SizedBox(height: 24),
                  _buildProfessionalInfoSection(),
                  const SizedBox(height: 32),
                  _buildSectionHeader(
                    'Ubicación',
                    'Selecciona tu ubicación paso a paso',
                    Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 24),
                  // =============== CAMBIO: Reemplazar CountryStateCityPicker ===============
                  _buildLocationSectionWithPeruLocationPicker(),
                  // =========================================================================
                  const SizedBox(height: 40),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryMetraShop.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryMetraShop,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 48),
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTextFormField(
            controller: _nameController,
            label: 'Nombre completo',
            hint: 'Ingresa tu nombre completo',
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 20),
          _buildTextFormField(
            controller: _phoneController,
            label: 'Teléfono',
            hint: 'Ingresa tu número de teléfono',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDropdownField(
            value: _employmentController.text.isEmpty || !_occupations.contains(_employmentController.text)
                ? _occupations.first : _employmentController.text,
            items: _occupations,
            label: 'Ocupación',
            icon: Icons.work_outline_rounded,
            onChanged: (value) {
              if (value != null && value != _occupations.first) {
                setState(() {
                  _employmentController.text = value;
                  _showCustomOccupationField = (value == 'Otro');

                  // Si no es "Otro", limpiar el campo personalizado
                  if (value != 'Otro') {
                    _customOccupationController.clear();
                  }
                });
                _onFormChanged();
              }
            },
          ),

          // Campo personalizado con animación
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _showCustomOccupationField
                ? Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildTextFormField(
                        controller: _customOccupationController,
                        label: 'Especifica tu ocupación',
                        hint: 'Ejemplo: Supervisor, Electricista, etc.',
                        icon: Icons.edit_outlined,
                        validator: (value) {
                          if (_showCustomOccupationField && (value == null || value.trim().isEmpty)) {
                            return 'Por favor especifica tu ocupación';
                          }
                          return null;
                        },
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // =============== NUEVO: Sección con PeruLocationPicker ===============
  Widget _buildLocationSectionWithPeruLocationPicker() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          MultiCountryLocationPicker(
            countryController: _countryController,
            level2Controller: _stateController,    // Nivel 2: Departamento/Estado
            level3Controller: _cityController,     // Nivel 3: Provincia/Municipio
            level4Controller: _districtController, // Nivel 4: Distrito/Corregimiento
            initialCountryCode: 'PE', // País inicial: Perú
            spacing: 20.0, // Espaciado entre campos
            onCountryChanged: _onFormChanged,
            onLevel2Changed: _onFormChanged,
            onLevel3Changed: _onFormChanged,
            onLevel4Changed: _onFormChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        fillColor: AppColors.neutral50,
        filled: true,
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.7), fontSize: 14),
      ),
    );
  }

  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required String label,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        fillColor: AppColors.neutral50,
        filled: true,
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      ),
    );
  }

  // =============== MANTENER: Botones de acción originales ===============
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Botón principal - Guardar cambios
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _formChanged && !_isLoading ? _saveChanges : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: _formChanged ? 2 : 0,
            ),
            child: _isLoading
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
              ),
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.save_outlined, size: 20),
                SizedBox(width: 8),
                Text(
                  'Guardar Cambios',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        if (_formChanged) ...[
          const SizedBox(height: 12),
          // Botón secundario - Descartar cambios
          SizedBox(
            width: double.infinity,
            height: 45,
            child: OutlinedButton(
              onPressed: _isLoading ? null : _discardChanges,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.restore_outlined, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Descartar cambios',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  // =============== AGREGAR: Diálogos de feedback ===============
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.success,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Perfil Actualizado',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: const Text(
            'Tu información de perfil se ha actualizado correctamente.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Recargar perfil para refrescar la pantalla anterior
                context.read<ProfileBloc>().add(LoadProfile(forceReload: true));
              },
              child: const Text(
                'Continuar',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Error',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cerrar',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}