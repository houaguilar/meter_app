import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:country_state_city_pro/country_state_city_pro.dart';
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
  late TextEditingController _districtController;

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

  // =============== AGREGADO: Para refrescar cuando vuelves a la pantalla ===============
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
  // ==================================================================================

  void _initializeControllers() {
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _employmentController = TextEditingController();
    _districtController = TextEditingController();

    final state = context.read<ProfileBloc>().state;
    if (state is ProfileLoaded) {
      _populateControllers(state.userProfile);
    }
  }

  void _populateControllers(dynamic profile) {
    // =============== MEJORADO: Solo actualizar si es diferente ===============
    if (_nameController.text != (profile.name ?? '')) {
      _nameController.text = profile.name ?? '';
    }
    if (_phoneController.text != (profile.phone ?? '')) {
      _phoneController.text = profile.phone ?? '';
    }
    if (_employmentController.text != (profile.employment ?? '')) {
      _employmentController.text = profile.employment ?? '';
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
    // =========================================================================
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
    // =============== QUITADO: Validación obligatoria ===============
    // No validamos el formulario para que los campos sean opcionales
    setState(() {
      _isLoading = true;
    });

    final profileBloc = context.read<ProfileBloc>();

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
      _isLoading = false;
      _formChanged = false;
    });
  }

  // =============== AGREGADO: Método para descartar cambios ===============
  void _discardChanges() {
    final state = context.read<ProfileBloc>().state;
    if (state is ProfileLoaded) {
      _populateControllers(state.userProfile);
      setState(() {
        _formChanged = false;
      });
    }
  }

  // =============== AGREGADO: Confirmación al salir ===============
  Future<bool> _onWillPop() async {
    if (!_formChanged) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Salir sin guardar?'),
        content: Text('Tienes cambios sin guardar. ¿Estás seguro de que quieres salir?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Salir sin guardar'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }
  // =====================================================================

  @override
  Widget build(BuildContext context) {
    // =============== AGREGADO: WillPopScope para confirmación ===============
    return WillPopScope(
      onWillPop: _onWillPop,
      child: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            _populateControllers(state.userProfile);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Form(
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
                    'Selecciona tu ubicación paso a paso',
                    Icons.location_on_outlined,
                  ),
                  SizedBox(height: 24),
                  _buildLocationSectionWithCountryStateCityPro(),
                  SizedBox(height: 40),
                  _buildActionButtons(),
                  SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    // ===================================================================
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
            icon: Icons.person_outline_rounded,
            // =============== QUITADO: validator obligatorio ===============
          ),
          SizedBox(height: 20),
          _buildTextFormField(
            controller: _phoneController,
            label: 'Teléfono',
            hint: 'Ingresa tu número de teléfono',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            // =============== QUITADO: validator obligatorio ===============
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
            value: _employmentController.text.isEmpty || !_occupations.contains(_employmentController.text)
                ? _occupations.first : _employmentController.text,
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
          // =============== CORREGIDO: Sin parámetros que no existen en v0.0.6 ===============
          CountryStateCityPicker(
            country: _countryController,
            state: _stateController,
            city: _cityController,
            dialogColor: AppColors.surface,
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
          // ===============================================================================

          SizedBox(height: 20),

          _buildTextFormField(
            controller: _districtController,
            label: 'Distrito',
            hint: 'Ingresa tu distrito',
            icon: Icons.location_city_outlined,
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
      // =============== QUITADO: validator obligatorio ===============
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
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
}