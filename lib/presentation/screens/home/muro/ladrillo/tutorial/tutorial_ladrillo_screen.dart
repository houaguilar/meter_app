import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/config/constants/colors.dart';

import '../../../../widgets/widgets.dart';

class TutorialLadrilloScreen extends StatelessWidget {
  const TutorialLadrilloScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(titleAppBar: 'Tutorial',),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildTutorialContent(context),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  context.pushNamed('ladrillo1');
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  fixedSize: const Size(200, 50),
                  backgroundColor: AppColors.orange
                ),
                child: const Text('Empecemos',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30,)
          ],
        ),
      ),
    );
  }

  Widget _buildTutorialContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          'assets/images/screen.png', // Ruta de la imagen en tus assets
          fit: BoxFit.cover,
        ),
      ],
    );
  }
}
