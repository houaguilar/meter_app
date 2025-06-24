import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  late TextEditingController _nationalityController;
  late TextEditingController _cityController;
  late TextEditingController _provinceController;
  late TextEditingController _districtController;

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
    _nationalityController = TextEditingController();
    _cityController = TextEditingController();
    _provinceController = TextEditingController();
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
    _nationalityController.text = profile.nationality ?? '';
    _cityController.text = profile.city ?? '';
    _provinceController.text = profile.province ?? '';
    _districtController.text = profile.district ?? '';
  }

  void _setupListeners() {
    _nameController.addListener(_onFormChanged);
    _phoneController.addListener(_onFormChanged);
    _employmentController.addListener(_onFormChanged);
    _nationalityController.addListener(_onFormChanged);
    _cityController.addListener(_onFormChanged);
    _provinceController.addListener(_onFormChanged);
    _districtController.addListener(_onFormChanged);
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
    _nationalityController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _districtController.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final profileBloc = context.read<ProfileBloc>();

      // Update profile with individual field updates to avoid null issues
      profileBloc.add(UpdateProfile(
        name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : null,
        phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
        employment: _employmentController.text.trim().isNotEmpty && _employmentController.text.trim() != 'Seleccione una ocupación'
            ? _employmentController.text.trim() : null,
        nationality: _nationalityController.text.trim().isNotEmpty ? _nationalityController.text.trim() : null,
        city: _cityController.text.trim().isNotEmpty ? _cityController.text.trim() : null,
        province: _provinceController.text.trim().isNotEmpty ? _provinceController.text.trim() : null,
        district: _districtController.text.trim().isNotEmpty ? _districtController.text.trim() : null,
      ));

      // Submit the profile changes
      profileBloc.add(SubmitProfile());

      setState(() {
        _formChanged = false;
        _isLoading = false;
      });
    }
  }

  void _resetForm() {
    final state = context.read<ProfileBloc>().state;
    if (state is ProfileLoaded) {
      _populateControllers(state.userProfile);
      setState(() {
        _formChanged = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded && !_formChanged) {
          _populateControllers(state.userProfile);
        }
        if (state is ProfileLoading) {
          setState(() {
            _isLoading = true;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      },
      builder: (context, state) {
        if (state is ProfileLoading && !_formChanged) {
          return _buildLoadingState();
        }

        return _buildForm();
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              strokeWidth: 3,
            ),
            SizedBox(height: 16),
            Text(
              'Cargando información del perfil...',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background,
            AppColors.surfaceVariant,
          ],
        ),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
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
                'Información sobre tu lugar de residencia',
                Icons.location_on_outlined,
              ),
              SizedBox(height: 24),
              _buildLocationSection(),
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
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
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
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
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
            label: 'Nombre completo',
            hint: 'Ingresa tu nombre completo',
            icon: Icons.badge_outlined,
            validator: (value) {
              if (value?.trim().isEmpty ?? true) {
                return 'El nombre es requerido';
              }
              if (value!.trim().length < 2) {
                return 'El nombre debe tener al menos 2 caracteres';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          _buildTextFormField(
            controller: _phoneController,
            label: 'Teléfono',
            hint: 'Ejemplo: +51 999 999 999',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value?.trim().isNotEmpty ?? false) {
                if (value!.trim().length < 8) {
                  return 'Ingresa un número de teléfono válido';
                }
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          _buildTextFormField(
            controller: _nationalityController,
            label: 'Nacionalidad',
            hint: 'Ejemplo: Peruana',
            icon: Icons.flag_outlined,
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

  Widget _buildLocationSection() {
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
            controller: _cityController,
            label: 'Ciudad',
            hint: 'Ejemplo: Lima',
            icon: Icons.location_city_outlined,
          ),
          SizedBox(height: 20),
          _buildTextFormField(
            controller: _provinceController,
            label: 'Provincia/Departamento',
            hint: 'Ejemplo: Lima',
            icon: Icons.map_outlined,
          ),
          SizedBox(height: 20),
          _buildTextFormField(
            controller: _districtController,
            label: 'Distrito',
            hint: 'Ejemplo: Miraflores',
            icon: Icons.place_outlined,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.7),
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Container(
              margin: EdgeInsets.all(12),
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
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required String label,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: items.contains(value) ? value : items.first,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 16,
                  color: item == items.first ? AppColors.textSecondary : AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: Container(
              margin: EdgeInsets.all(12),
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
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
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
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _formChanged && !_isLoading ? _saveChanges : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _formChanged ? AppColors.primary : AppColors.border,
                foregroundColor: AppColors.white,
                elevation: _formChanged ? 4 : 0,
                shadowColor: AppColors.primary.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  strokeWidth: 2,
                ),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.save_outlined,
                    size: 22,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Guardar cambios',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_formChanged) ...[
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: _isLoading ? null : _resetForm,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppColors.border),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.refresh_outlined,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Deshacer cambios',
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
      ),
    );
  }
}