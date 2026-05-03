import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'tutorial_event.dart';
part 'tutorial_state.dart';

class TutorialBloc extends Bloc<TutorialEvent, TutorialState> {
  final int totalSteps;

  TutorialBloc({required this.totalSteps}) : super(TutorialInitial()) {
    on<TutorialNext>((event, emit) {
      if (state is TutorialInitial) {
        emit(TutorialStep(1));
      } else if (state is TutorialStep) {
        final currentIndex = (state as TutorialStep).stepIndex;
        if (currentIndex < totalSteps) {
          emit(TutorialStep(currentIndex + 1));
        } else {
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
      emit(TutorialCompleted());
    });
  }
}
