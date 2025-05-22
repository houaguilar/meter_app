import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/data/local/shared_preferences_helper.dart';
import 'package:meter_app/init_dependencies.dart';
import 'package:meter_app/presentation/assets/icons.dart';
import 'package:meter_app/presentation/widgets/buttons/custom_icon_elevated_button.dart';
import 'package:meter_app/presentation/widgets/shared/wave_header.dart';

import '../../../../config/theme/theme.dart';
import '../../../assets/images.dart';
import '../../../widgets/widgets.dart';


class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int _currentIndex = 0;
  late final SharedPreferencesHelper _sharedPreferencesHelper;

  @override
  void initState() {
    super.initState();
    _sharedPreferencesHelper = serviceLocator<SharedPreferencesHelper>();
    _checkFirstTimeUser();
  }

  Future<void> _checkFirstTimeUser() async {
    if (!_sharedPreferencesHelper.isFirstTimeUser()) {
    //  _navigateToHome();
    }
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 0));
    if (mounted) {
      context.goNamed('home');
    }
  }

  Future<void> _completeWelcome() async {
    await _sharedPreferencesHelper.setFirstTimeUser(false);
    _navigateToHome();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.35,
              child: Stack(
                  children: [
                    const WaveHeader(height: 185),
                    Center(
                      child: SvgPicture.asset(
                        AppImages.onboardingWelcomeImg,
                        height: MediaQuery.of(context).size.height * 0.27,
                      ),
                    )
                  ]
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.only(right: 24, left: 24),
              child: Text(
                'Bienvenido a Metrashop',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  fontFamily: 'assets/fonts/Poppins-Bold.ttf',
                  color: AppColors.leadTextColor
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 15),
            const Padding(
              padding: EdgeInsets.only(right: 24, left: 24),
              child: Text(
                'Esta plataforma te ayudará a poder realizar mediciones y calcular la cantidad de material que necesitas para tus proyectos.',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.only(right: 24, left: 24),
              child: Text(
                '¡Sácale el mayor provecho!',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
            // Información adicional
            const Padding(
              padding: EdgeInsets.only(right: 24, left: 24),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  '¿Qué encontrarás en la app?',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: CarouselCards(
                onPageChanged: _onPageChanged,
              ),
            ),
            const SizedBox(height: 20),
            // Indicadores de página (puntos)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 33 : 21,
                  height: _currentIndex == index ? 8 : 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == index ? AppColors.blueMetraShop : AppColors.blueLightIndicator,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(left: 24, right: 24),
                child: CustomIconElevatedButton(
                  onPressed: _completeWelcome,
                  label: 'Comenzar',
                  icon: AppIcons.arrowRightIcon,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}