import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/config/constants/colors.dart';

import '../../../assets/images.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../widgets/widgets.dart';

class MetraShopScreen extends StatefulWidget {
  const MetraShopScreen({super.key});

  @override
  State<MetraShopScreen> createState() => _MetraShopScreenState();
}

class _MetraShopScreenState extends State<MetraShopScreen> {

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthIsUserLoggedIn());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Loader();
          } else if (state is AuthSuccess) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.goNamed('welcome');
            });
            return Container();
          } else {
            return const BuildMetraShopUI();
          }
        },
      ),
    );
  }
}

class BuildMetraShopUI extends StatelessWidget {
  const BuildMetraShopUI({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.47,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppImages.welcomeImg),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            color: AppColors.primaryMetraShop,
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20,),
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'METRA',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: 'SHOP',
                        style: TextStyle(
                          color: AppColors.blueMetraShop,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 90,),
                    CustomOutlinedWelcomeButton(
                      label: 'Iniciar sesión',
                      onPressed: () {
                        context.pushNamed('login');
                      },
                    ),
                    const SizedBox(height: 12,),
                    CustomOutlinedWelcomeButton(
                      label: 'Registrarme',
                      onPressed: () {
                        context.pushNamed('register');
                      },
                    ),
                    const SizedBox(height: 40,),
                    /*CustomTextYellowButton(
                      label: 'Continuar como invitado',
                      onPressed: () {},
                    ),*/
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}