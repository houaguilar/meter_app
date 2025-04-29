
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meter_app/presentation/blocs/profile/profile_bloc.dart';

import '../../../widgets/fields/profile_text_field.dart';

class ProfileSettingsTab extends StatelessWidget {
  const ProfileSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProfileLoaded) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ProfileTextField(
                  label: 'Contraseña antigua',
                  onChanged: (value) {
                    // Logica para manejar la contraseña antigua
                  },
                  obscureText: true,
                ),
                ProfileTextField(
                  label: 'Nueva contraseña',
                  onChanged: (value) {
                    // Logica para manejar la nueva contraseña
                  },
                  obscureText: true,
                ),
                ProfileTextField(
                  label: 'Confirmar contraseña',
                  onChanged: (value) {
                    // Logica para manejar la confirmación de la contraseña
                  },
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                SwitchListTile(
                  title: const Text('Activar las notificaciones'),
                  value: state.notificationsEnabled,
                  onChanged: (value) {
               //     context.read<ProfileBloc>().add(UpdateProfile(notificationsEnabled: value));
                  },
                ),
                SwitchListTile(
                  title: const Text('Mantener mi sesión abierta'),
                  value: state.keepSessionOpen,
                  onChanged: (value) {
                   // context.read<ProfileBloc>().add(UpdateProfile(keepSessionOpen: value));
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: state.isValid
                      ? () {
                    // Aquí se podría manejar la lógica para guardar cambios de configuración
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
