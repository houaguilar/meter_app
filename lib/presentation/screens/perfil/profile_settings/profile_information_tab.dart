import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meter_app/presentation/blocs/profile/profile_bloc.dart';

import '../../../../config/theme/theme.dart';

class ProfileInformationTab extends StatefulWidget {
  const ProfileInformationTab({super.key});

  @override
  State<ProfileInformationTab> createState() => _ProfileInformationTabState();
}

class _ProfileInformationTabState extends State<ProfileInformationTab> {
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
    'Otro'
  ];

  bool _formChanged = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _employmentController = TextEditingController();
    _nationalityController = TextEditingController();
    _cityController = TextEditingController();
    _provinceController = TextEditingController();
    _districtController = TextEditingController();

    // Initialize controllers from bloc state if available
    final state = context.read<ProfileBloc>().state;
    if (state is ProfileLoaded) {
      final profile = state.userProfile;
      _nameController.text = profile.name;
      _phoneController.text = profile.phone;
      _employmentController.text = profile.employment;
      _nationalityController.text = profile.nationality;
      _cityController.text = profile.city;
      _provinceController.text = profile.province;
      _districtController.text = profile.district;
    }

    // Add listeners to detect form changes
    _nameController.addListener(_onFormChanged);
    _phoneController.addListener(_onFormChanged);
    _employmentController.addListener(_onFormChanged);
    _nationalityController.addListener(_onFormChanged);
    _cityController.addListener(_onFormChanged);
    _provinceController.addListener(_onFormChanged);
    _districtController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    setState(() {
      _formChanged = true;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _employmentController.dispose();
    _nationalityController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          // Only update controllers if they're not being edited
          if (!_formChanged) {
            final profile = state.userProfile;
            _nameController.text = profile.name;
            _phoneController.text = profile.phone;
            _employmentController.text = profile.employment;
            _nationalityController.text = profile.nationality;
            _cityController.text = profile.city;
            _provinceController.text = profile.province;
            _districtController.text = profile.district;
          }
        }
      },
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProfileLoaded) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información Personal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryMetraShop,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _nameController,
                    label: 'Nombre y apellido',
                    hint: 'Ingrese su nombre completo',
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su nombre';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Teléfono',
                    hint: 'Ingrese su número de teléfono',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su número de teléfono';
                      }
                      // Corrección de la expresión regular
                      if (!RegExp(r'^\d{9,10}$').hasMatch(value)) {
                        return 'Por favor ingrese un número válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    label: 'Ocupación',
                    currentValue: _employmentController.text.isNotEmpty
                        ? _employmentController.text
                        : _occupations[0],
                    items: _occupations,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _employmentController.text = value;
                          _formChanged = true;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Ubicación',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryMetraShop,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _nationalityController,
                    label: 'Nacionalidad',
                    hint: 'Ingrese su nacionalidad',
                    icon: Icons.flag_outlined,
                  ),
                  _buildTextField(
                    controller: _cityController,
                    label: 'Ciudad',
                    hint: 'Ingrese su ciudad',
                    icon: Icons.location_city_outlined,
                  ),
                  _buildTextField(
                    controller: _provinceController,
                    label: 'Provincia',
                    hint: 'Ingrese su provincia',
                    icon: Icons.map_outlined,
                  ),
                  _buildTextField(
                    controller: _districtController,
                    label: 'Distrito',
                    hint: 'Ingrese su distrito',
                    icon: Icons.place_outlined,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blueMetraShop,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _formChanged ? _saveProfile : null,
                      child: const Text(
                        'Guardar cambios',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (state is ProfileError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error: ${state.message}',
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<ProfileBloc>().add(LoadProfile());
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }
        return const Center(child: Text('No se pudo cargar el perfil'));
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
        ),
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String currentValue,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
          prefixIcon: const Icon(Icons.work_outline),
        ),
        value: items.contains(currentValue) ? currentValue : items[0],
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // Update profile in bloc
      context.read<ProfileBloc>().add(
        UpdateProfile(
          name: _nameController.text,
          phone: _phoneController.text,
          employment: _employmentController.text,
          nationality: _nationalityController.text,
          city: _cityController.text,
          province: _provinceController.text,
          district: _districtController.text,
        ),
      );

      // Submit profile to save changes
      context.read<ProfileBloc>().add(SubmitProfile());

      // Reset form changed state
      setState(() {
        _formChanged = false;
      });
    }
  }
}