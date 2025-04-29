
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meter_app/config/constants/constants.dart';

import '../../../assets/images.dart';
import '../../../../config/utils/show_snackbar.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../widgets/widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Validación del nombre completo
  String? _validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Por favor, introduce tu nombre completo';
    }
    return null;
  }

  // Reutilización de las validaciones de correo y contraseña
  String? _validateEmail(String? email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (email == null || email.isEmpty) {
      return 'Por favor, introduce tu correo electrónico';
    } else if (!emailRegex.hasMatch(email)) {
      return 'Introduce un correo electrónico válido';
    }
    return null;
  }

  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Por favor, introduce tu contraseña';
    }
    if (password.length < 5) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasDigits = password.contains(RegExp(r'[0-9]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));

    if (!hasUppercase) return 'La contraseña debe contener al menos una letra mayúscula';
    if (!hasDigits) return 'La contraseña debe contener al menos un número';
    if (!hasLowercase) return 'La contraseña debe contener al menos una letra minúscula';

    return null;
  }

  // Validación de la confirmación de contraseña
  String? _validateConfirmPassword(String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Por favor, confirma tu contraseña';
    }
    if (confirmPassword != _passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              showSnackBar(context, state.message);
            } else if (state is AuthSuccess) {
              context.goNamed('welcome');
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Loader();
            }

            return Stack(
              children: [
                Stack(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.22,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(AppImages.registerImg),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                  ],
                ),
                SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 0.20,
                          color: Colors.transparent,
                        ),
                        Positioned(
                          bottom: 10,
                          left: 20,
                          child: Text(
                            'METRASHOP',
                            style: GoogleFonts.poppins(textStyle:const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 2),
                                  blurRadius: 6,
                                  color: Colors.black45,
                                ),
                              ],
                            ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 6),
                              const Text(
                                'Registrarme',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primaryMetraShop,
                                ),
                              ),
                              const SizedBox(height: 30),
                              AuthFormField(
                                hintText: 'Nombre y apellido',
                                controller: _nameController,
                                keyboardType: TextInputType.name,
                                isPassword: false,
                                validator: _validateName,
                              ),
                              const SizedBox(height: 15),
                              AuthFormField(
                                hintText: 'Correo',
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                isPassword: false,
                                validator: _validateEmail,
                              ),
                              const SizedBox(height: 15),
                              AuthFormField(
                                hintText: 'Contraseña',
                                controller: _passwordController,
                                keyboardType: TextInputType.text,
                                isPassword: true,
                                isIconVisible: true,
                                validator: _validatePassword,
                              ),
                              const SizedBox(height: 15),
                              AuthFormField(
                                hintText: 'Confirmar contraseña',
                                controller: _confirmPasswordController,
                                keyboardType: TextInputType.text,
                                isPassword: true,
                                isIconVisible: true,
                                validator: _validateConfirmPassword,
                              ),
                              const SizedBox(height: 30),
                              CustomElevatedButton(
                                label: 'Aceptar y unirme',
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    context.read<AuthBloc>().add(
                                      AuthSignUp(
                                        email: _emailController.text.trim(),
                                        password: _passwordController.text.trim(),
                                        name: _nameController.text.trim(),
                                      ),
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: CustomIconOutlinedButton(
                                      label: 'Unirme con Google',
                                      icon: Icons.g_mobiledata_rounded,
                                      onPressed: () {},
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: CustomIconOutlinedButton(
                                      label: 'Unirme con Facebook',
                                      icon: Icons.facebook,
                                      onPressed: () {},
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ]
            );
          },
        ),
      ),
    );
  }
}