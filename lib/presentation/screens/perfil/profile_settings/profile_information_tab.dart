
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meter_app/presentation/blocs/profile/profile_bloc.dart';

import '../../../widgets/dropdown/profile_dropdown_field.dart';
import '../../../widgets/fields/profile_text_field.dart';

class ProfileInformationTab extends StatefulWidget {
  const ProfileInformationTab({super.key});

  @override
  State<ProfileInformationTab> createState() => _ProfileInformationTabState();
}

class _ProfileInformationTabState extends State<ProfileInformationTab> {


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProfileLoaded) {
          final userProfile = state.userProfile;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ProfileTextField(
                  label: 'Nombre y Apellido',
                  initialValue: userProfile.name,
                  onChanged: (value) {
                    context.read<ProfileBloc>().add(UpdateProfile(name: value));
                  },
                ),
                ProfileTextField(
                  label: 'Celular',
                  initialValue: userProfile.phone,
                  onChanged: (value) {
                    context.read<ProfileBloc>().add(UpdateProfile(phone: value));
                  },
                ),
                ProfileDropdownField(
                  label: 'Ocupación',
                  value: userProfile.employment.isNotEmpty
                      ? userProfile.employment
                      : 'Seleccione una ocupación',  // Valor por defecto
                  items: const ['Seleccione una ocupación', 'Operario', 'Arquitecto', 'Ingeniero civil'],
                  onChanged: (value) {
                    context.read<ProfileBloc>().add(UpdateProfile(employment: value));
                  },
                ),
                ProfileTextField(
                  label: 'Nacionalidad',
                  initialValue: userProfile.nationality,
                  onChanged: (value) {
                    context.read<ProfileBloc>().add(UpdateProfile(nationality: value));
                  },
                ),
                ProfileTextField(
                  label: 'Ciudad',
                  initialValue: userProfile.city,
                  onChanged: (value) {
                    context.read<ProfileBloc>().add(UpdateProfile(city: value));
                  },
                ),
                ProfileTextField(
                  label: 'Provincia',
                  initialValue: userProfile.province,
                  onChanged: (value) {
                    context.read<ProfileBloc>().add(UpdateProfile(province: value));
                  },
                ),
                ProfileTextField(
                  label: 'Distrito',
                  initialValue: userProfile.district,
                  onChanged: (value) {
                    context.read<ProfileBloc>().add(UpdateProfile(district: value));
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: state.isValid
                      ? () {
                    context.read<ProfileBloc>().add(SubmitProfile());
                  }
                      : null,
                  child: const Text('Guardar datos'),
                ),
              ],
            ),
          );
        } else if (state is ProfileError) {
          return Center(child: Text(state.message));
        } else {
          return const Center(child: Text('Error desconocido.'));
        }
      },
    );
  }
}
