import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'tutorial_event.dart';
part 'tutorial_state.dart';

class TutorialBloc extends Bloc<TutorialEvent, TutorialState> {
  final int totalSteps;

  TutorialBloc({required this.totalSteps}) : super(TutorialInitial()) {
    on<TutorialNext>((event, emit) {
      if (state is TutorialInitial) {
        print("Cambiando de TutorialInitial a TutorialStep(1)");
        emit(TutorialStep(1));
      } else if (state is TutorialStep) {
        final currentIndex = (state as TutorialStep).stepIndex;
        if (currentIndex < totalSteps) {
          print("Avanzando al siguiente paso: TutorialStep(${currentIndex + 1})");
          emit(TutorialStep(currentIndex + 1));
        } else {
          print("Tutorial completado");
          emit(TutorialCompleted());
        }
      }
    });

    on<TutorialPrevious>((event, emit) {
      if (state is TutorialStep) {
        final currentIndex = (state as TutorialStep).stepIndex;
        if (currentIndex > 1) {
          emit(TutorialStep(currentIndex - 1));
        } else {
          emit(TutorialInitial());
        }
      }
    });

    on<TutorialSkip>((event, emit) {
      print("Tutorial saltado");
      emit(TutorialCompleted());
    });
  }
}
