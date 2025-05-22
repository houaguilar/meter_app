import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/presentation/widgets/buttons/custom_elevated_button.dart';
import 'package:meter_app/presentation/widgets/buttons/custom_text_blue_button.dart';
import 'package:meter_app/presentation/widgets/shared/info_box.dart';

import '../../../../../../config/theme/theme.dart';
import '../../../../../../domain/entities/tutorial/tutorial_step.dart';
import '../../../../../blocs/tutorial/tutorial_bloc.dart';


class TutorialOverlay extends StatelessWidget {
final VoidCallback onSkip;

// Lista de pasos del tutorial
  final List<TutorialStepData> steps = [
    TutorialStepData(
      title: "¿Qué debes hacer?",
      description: "Ingresa la descripción para el proyecto.\nSi ya tienes el área completa ingrésala, de no ser \nasí, coloca las medidas, nosotros te ayudaremos.",
      imagePath: "assets/images/onboarding_tutorial.svg",
    ),
    TutorialStepData(
      title: "¿Qué debes hacer?",
      description: "Elige el tipo de asentado que utilizarás para tu \nproyecto. Si no lo sabes, aquí te brindaremos las \nopciones.",
      imagePath: "assets/images/piso_tutorial.svg",
    ),
    TutorialStepData(
      title: "¿Qué debes hacer?",
      description: "Podrás añadir diferentes secciones al proyecto \npara tener cada espacio metrado.",
      imagePath: "assets/images/column_tutorial.svg",
    ),
  ];

  TutorialOverlay({super.key, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocProvider(
        create: (_) => TutorialBloc(totalSteps: steps.length),
        child: BlocBuilder<TutorialBloc, TutorialState>(
          builder: (context, state) {
            print('Estado actual: $state'); // Verifica el estado en el BlocBuilder

            if (state is TutorialInitial) {
              return TutorialStepWidget(step: steps[0], stepIndex: 0, onSkip: onSkip);
            } else if (state is TutorialStep) {
              final stepIndex = state.stepIndex;
              return TutorialStepWidget(step: steps[stepIndex], stepIndex: stepIndex, onSkip: onSkip);
            } else if (state is TutorialCompleted) {
              context.pop();  // Aquí navega fuera cuando el tutorial se completa
              return Container(); // Placeholder mientras navega
            }
            return Container(); // Placeholder para otros casos
          },
        ),
      ),
    );
  }
}

class TutorialStepWidget extends StatelessWidget {
  final TutorialStepData step;
  final int stepIndex;
  final VoidCallback onSkip;

  const TutorialStepWidget({super.key, required this.step, required this.stepIndex, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  if (stepIndex > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        BlocProvider.of<TutorialBloc>(context).add(TutorialPrevious());
                      },
                    ),
                  if (stepIndex > 0)
                    Text('Paso ${stepIndex + 1}'),
                ],
              ),
              Text(step.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primaryMetraShop)),
              const SizedBox(height: 16),
              SizedBox(height: 200,child: SvgPicture.asset(step.imagePath)),
              const SizedBox(height: 16),
              Text('Paso ${stepIndex + 1}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),),
              const SizedBox(height: 16),
              Text(step.description, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              const InfoBox(message: 'Recuerda que los datos que brindaremos son aproximados. Procura introducir datos exactos.'),
              const SizedBox(height: 20),
             CustomElevatedButton(
                label: stepIndex == 2 ? "Empezar" : "Siguiente",
                onPressed: () {
                  if (stepIndex == 2) {
                    onSkip();  // Se asegura de que onSkip se ejecuta al final del tutorial
                  } else {
                    print("Enviando evento TutorialNext");
                    BlocProvider.of<TutorialBloc>(context).add(TutorialNext());  // Se asegura de que el evento TutorialNext es enviado
                  }
                },
              ),

              CustomTextBlueButton(
                label: "Omitir tutorial",
                onPressed: onSkip,
              ),
            ],
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: onSkip,
          ),
        ),
      ],
    );
  }
}
