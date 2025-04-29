import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meter_app/presentation/blocs/profile/profile_bloc.dart';

class ProfileImageTab extends StatefulWidget {
  const ProfileImageTab({super.key});

  @override
  State<ProfileImageTab> createState() => _ProfileImageTabState();
}

class _ProfileImageTabState extends State<ProfileImageTab> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source, maxWidth: 600, maxHeight: 600);
      if (pickedFile == null) {
        throw Exception('No se seleccionó ningún archivo.');
      }

      final file = File(pickedFile.path);
      if (!await file.exists()) {
        throw Exception('El archivo seleccionado no existe.');
      }
      if (pickedFile != null) {
        // Despachar evento para actualizar la imagen
        context.read<ProfileBloc>().add(UpdateProfileImageEvent(pickedFile.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar la imagen: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProfileLoaded) {
          final userProfile = state.userProfile;

          return Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: userProfile.profileImageUrl != null &&
                      userProfile.profileImageUrl!.isNotEmpty
                      ? (userProfile.profileImageUrl!.startsWith('http')
                      ? NetworkImage(userProfile.profileImageUrl!)
                      : FileImage(File(userProfile.profileImageUrl!)) as ImageProvider)
                      : null,
                  child: userProfile.profileImageUrl == null ||
                      userProfile.profileImageUrl!.isEmpty
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _pickImage(context, ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Tomar una foto'),
              ),
              ElevatedButton.icon(
                onPressed: () => _pickImage(context, ImageSource.gallery),
                icon: const Icon(Icons.image),
                label: const Text('Seleccionar de la galería'),
              ),
            ],
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
