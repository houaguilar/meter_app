import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:meter_app/config/constants/colors.dart';
import 'package:meter_app/presentation/blocs/profile/profile_bloc.dart';

class ProfileImageTab extends StatefulWidget {
  const ProfileImageTab({super.key});

  @override
  State<ProfileImageTab> createState() => _ProfileImageTabState();
}

class _ProfileImageTabState extends State<ProfileImageTab> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _processing = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoading) {
          setState(() {
            _processing = true;
          });
        } else {
          setState(() {
            _processing = false;
          });
        }
      },
      builder: (context, state) {
        if (state is ProfileLoaded) {
          final userProfile = state.userProfile;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Foto de perfil',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryMetraShop,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sube una foto para personalizar tu perfil',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Profile image display
                Hero(
                  tag: 'profile-image',
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Material(
                        elevation: 4,
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: SizedBox(
                          width: 180,
                          height: 180,
                          child: _imageFile != null
                              ? ClipOval(
                            child: Image.file(
                              _imageFile!,
                              fit: BoxFit.cover,
                            ),
                          )
                              : (userProfile.profileImageUrl?.isNotEmpty == true
                              ? ClipOval(
                            child: Image.network(
                              userProfile.profileImageUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ?? 1)
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.person, size: 80, color: Colors.grey),
                            ),
                          )
                              : Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.person, size: 80, color: Colors.grey),
                          )
                          ),
                        ),
                      ),

                      // Processing indicator overlay
                      if (_processing)
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Image source options
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Camera button
                    Expanded(
                      child: _buildSourceButton(
                        icon: Icons.camera_alt,
                        label: 'Cámara',
                        onTap: () => _pickImage(ImageSource.camera),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Gallery button
                    Expanded(
                      child: _buildSourceButton(
                        icon: Icons.photo_library,
                        label: 'Galería',
                        onTap: () => _pickImage(ImageSource.gallery),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Upload button - only shown when an image is selected
                if (_imageFile != null)
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
                      onPressed: _processing ? null : _uploadImage,
                      child: const Text(
                        'Subir imagen',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // Remove image option
                if (userProfile.profileImageUrl?.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: TextButton.icon(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text(
                        'Eliminar foto',
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: _processing ? null : _confirmRemoveImage,
                    ),
                  ),
              ],
            ),
          );
        } else if (state is ProfileLoading) {
          return const Center(child: CircularProgressIndicator());
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

  Widget _buildSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primaryMetraShop,
        elevation: 2,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      icon: Icon(icon),
      label: Text(label),
      onPressed: _processing ? null : onTap,
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    // Request permission first
    final permissionStatus = source == ImageSource.camera
        ? await Permission.camera.request()
        : await Permission.photos.request();

    if (permissionStatus.isGranted) {
      try {
        final pickedFile = await _picker.pickImage(
          source: source,
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 85, // Reduce quality for better performance
        );

        if (pickedFile != null) {
          setState(() {
            _imageFile = File(pickedFile.path);
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar la imagen: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Se requieren permisos para acceder a la cámara o galería'),
        ),
      );
    }
  }

  void _uploadImage() {
    if (_imageFile != null) {
      context.read<ProfileBloc>().add(UpdateProfileImageEvent(_imageFile!.path));
    }
  }

  Future<void> _confirmRemoveImage() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar foto de perfil'),
        content: const Text('¿Estás seguro de que quieres eliminar tu foto de perfil?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      context.read<ProfileBloc>().add(
        UpdateProfile(profileImageUrl: ''),
      );
      context.read<ProfileBloc>().add(SubmitProfile());
    }
  }
}