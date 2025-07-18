import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:country_state_city_pro/country_state_city_pro.dart'; // Librería actualizada y estable
import 'package:meter_app/presentation/blocs/profile/profile_bloc.dart';
import '../../../../config/theme/theme.dart';

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
  late TextEditingController _districtController; // Mantenemos distrito por separado

  // Controllers para country_state_city_pro
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  final List<String> _occupations = [
    'Seleccione una ocupación',
    'Arquitecto',
    'Ingeniero Civil',
    'Contratista',
    'Albañil',
    'Operario',
    'Maestro de Obra',
    'Técnico en Construcción',
    'Inspector de Obras',
    'Supervisor de Proyectos',
    'Otro'
  ];

  bool _formChanged = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupListeners();
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _employmentController = TextEditingController();
    _districtController = TextEditingController();

    // Initialize from bloc state if available
    final state = context.read<ProfileBloc>().state;
    if (state is ProfileLoaded) {
      _populateControllers(state.userProfile);
    }
  }

  void _populateControllers(dynamic profile) {
    _nameController.text = profile.name ?? '';
    _phoneController.text = profile.phone ?? '';
    _employmentController.text = profile.employment ?? '';
    _districtController.text = profile.district ?? '';

    // Inicializar valores de ubicación
    _countryController.text = profile.nationality ?? '';
    _stateController.text = profile.province ?? '';
    _cityController.text = profile.city ?? '';
  }

  void _setupListeners() {
    _nameController.addListener(_onFormChanged);
    _phoneController.addListener(_onFormChanged);
    _employmentController.addListener(_onFormChanged);
    _districtController.addListener(_onFormChanged);
    _countryController.addListener(_onFormChanged);
    _stateController.addListener(_onFormChanged);
    _cityController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    if (!_formChanged) {
      setState(() {
        _formChanged = true;
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
    _districtController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _cityController.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final profileBloc = context.read<ProfileBloc>();

      // Update profile con los valores de los controllers
      profileBloc.add(UpdateProfile(
        name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : null,
        phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
        employment: _employmentController.text.trim().isNotEmpty && _employmentController.text.trim() != 'Seleccione una ocupación'
            ? _employmentController.text.trim() : null,
        nationality: _countryController.text.trim().isNotEmpty ? _countryController.text.trim() : null,
        province: _stateController.text.trim().isNotEmpty ? _stateController.text.trim() : null,
        city: _cityController.text.trim().isNotEmpty ? _cityController.text.trim() : null,
        district: _districtController.text.trim().isNotEmpty ? _districtController.text.trim() : null,
      ));

      setState(() {
        _formChanged = false;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Perfil actualizado correctamente'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _discardChanges() {
    setState(() {
      _formChanged = false;
    });

    // Restaurar valores originales
    final state = context.read<ProfileBloc>().state;
    if (state is ProfileLoaded) {
      _populateControllers(state.userProfile);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cambios descartados'),
        backgroundColor: AppColors.neutral600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          setState(() {
            _isLoading = false;
          });
        } else if (state is ProfileError) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                'Información Personal',
                'Completa tu perfil para una mejor experiencia',
                Icons.person_outline_rounded,
              ),
              SizedBox(height: 24),
              _buildPersonalInfoSection(),
              SizedBox(height: 32),
              _buildSectionHeader(
                'Información Profesional',
                'Detalles sobre tu actividad laboral',
                Icons.work_outline_rounded,
              ),
              SizedBox(height: 24),
              _buildProfessionalInfoSection(),
              SizedBox(height: 32),
              _buildSectionHeader(
                'Ubicación',
                'Selecciona tu ubicación paso a paso',
                Icons.location_on_outlined,
              ),
              SizedBox(height: 24),
              _buildLocationSectionWithCountryStateCityPro(), // Nueva sección actualizada
              SizedBox(height: 40),
              _buildActionButtons(),
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTextFormField(
            controller: _nameController,
            label: 'Nombre Completo',
            hint: 'Ingresa tu nombre completo',
            icon: Icons.person_outline_rounded,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El nombre es requerido';
              }
              if (value.trim().length < 2) {
                return 'Ingresa un nombre válido';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          _buildTextFormField(
            controller: _phoneController,
            label: 'Teléfono',
            hint: 'Ejemplo: +51 987 654 321',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                if (value.trim().length < 8) {
                  return 'Ingresa un número de teléfono válido';
                }
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalInfoSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDropdownField(
            value: _employmentController.text.isEmpty ? _occupations.first : _employmentController.text,
            items: _occupations,
            label: 'Ocupación',
            icon: Icons.work_outline_rounded,
            onChanged: (value) {
              if (value != null && value != _occupations.first) {
                _employmentController.text = value;
                _onFormChanged();
              }
            },
          ),
        ],
      ),
    );
  }

  // Nueva sección de ubicación con country_state_city_pro
  Widget _buildLocationSectionWithCountryStateCityPro() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // CountryStateCityPicker Widget - MÁS ESTABLE
          CountryStateCityPicker(
            country: _countryController,
            state: _stateController,
            city: _cityController,

            // Color del diálogo de selección
            dialogColor: AppColors.surface,

            // Decoración personalizada de los campos
            textFieldDecoration: InputDecoration(
              fillColor: AppColors.neutral50,
              filled: true,
              suffixIcon: Icon(
                Icons.arrow_drop_down_rounded,
                color: AppColors.primary,
                size: 28,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.border.withOpacity(0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.border.withOpacity(0.5),
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              labelStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ),

          SizedBox(height: 20),

          // Campo adicional para distrito
          _buildTextFormField(
            controller: _districtController,
            label: 'Distrito',
            hint: 'Ejemplo: Miraflores, San Isidro, Surco',
            icon: Icons.place_outlined,
          ),

          SizedBox(height: 16),

          // Información adicional
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.info.withOpacity(0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.info,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Funcionalidad de búsqueda',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.info,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Toca cada campo para seleccionar. Puedes buscar escribiendo el nombre. Si no encuentras tu ciudad, puedes escribirla manualmente.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.info,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        filled: true,
        fillColor: AppColors.neutral50,
      ),
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required String label,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        filled: true,
        fillColor: AppColors.neutral50,
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: TextStyle(
              color: item == items.first ? AppColors.textSecondary : AppColors.textPrimary,
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value == items.first) {
          return 'Por favor selecciona una opción';
        }
        return null;
      },
    );
  }

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
                ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
              ),
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
          SizedBox(height: 12),
          // Botón secundario - Descartar cambios
          SizedBox(
            width: double.infinity,
            height: 45,
            child: OutlinedButton(
              onPressed: _isLoading ? null : _discardChanges,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: BorderSide(color: AppColors.border.withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh_outlined, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Descartar Cambios',
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

        // Indicador visual de estado
        if (_formChanged) ...[
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: AppColors.warning,
                ),
                SizedBox(width: 6),
                Text(
                  'Hay cambios sin guardar',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.warning,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}