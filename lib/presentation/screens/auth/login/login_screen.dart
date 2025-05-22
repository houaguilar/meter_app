
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/presentation/assets/images.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../config/theme/theme.dart';
import '../../../../config/utils/show_snackbar.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../widgets/widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Validación del correo electrónico
  String? _validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Por favor, introduce tu correo electrónico';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Introduce un correo electrónico válido';
    }
    return null;
  }

  // Validación de la contraseña
  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Por favor, introduce tu contraseña';
    }
    if (password.length < 5) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasDigits = password.contains(RegExp(r'[0-9]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));

    if (!hasUppercase) {
      return 'La contraseña debe contener al menos una letra mayúscula';
    }
    if (!hasDigits) {
      return 'La contraseña debe contener al menos un número';
    }
    if (!hasLowercase) {
      return 'La contraseña debe contener al menos una letra minúscula';
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
                          height: MediaQuery.of(context).size.height * 0.42,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(AppImages.loginImg),
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
                                  height: MediaQuery.of(context).size.height * 0.4,
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
                              ]
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
                                      'Iniciar Sesión',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.primaryMetraShop,
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    AuthFormField(
                                      hintText: 'Correo',
                                      controller: emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      isPassword: false,
                                      validator: _validateEmail,
                                    ),
                                    const SizedBox(height: 15),
                                    AuthFormField(
                                      hintText: 'Contraseña',
                                      controller: passwordController,
                                      keyboardType: TextInputType.text,
                                      isPassword: true,
                                      isIconVisible: true,
                                      validator: _validatePassword,
                                    ),
                                    const SizedBox(height: 30),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        Row(
                                          children: [
                                            Switch(
                                              value: _rememberMe,
                                              activeColor: AppColors.blueMetraShop,
                                              onChanged: (value) {
                                                setState(() {
                                                  _rememberMe = value;
                                                });
                                              },
                                            ),
                                            const Text('Recordarme',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppColors.greyTextSwitchColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                       Expanded(
                                         child: CustomTextBlueButton(
                                            onPressed: () {
                                              // Acción para ¿Olvidó su contraseña?
                                            },
                                              label:'¿Olvidó su contraseña?',
                                          ),
                                       ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    CustomElevatedButton(
                                      label: 'Ingresar',
                                      onPressed: () {
                                        FocusScope.of(context).unfocus();
                                        if (formKey.currentState!.validate()) {
                                          context.read<AuthBloc>().add(
                                            AuthLogin(
                                              email: emailController.text.trim(),
                                              password: passwordController.text.trim(),
                                              rememberMe: _rememberMe,
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
                                            label: 'Ingresar con Google',
                                            icon: Icons.g_mobiledata_rounded,
                                            onPressed: () {
                                              context.read<AuthBloc>().add(AuthLoginWithGoogle());
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: CustomIconOutlinedButton(
                                            label: 'Ingresar con Facebook',
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
        )
    );

  }
}