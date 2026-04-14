import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meter_app/domain/entities/feedback/feedback_entity.dart';
import 'package:meter_app/domain/usecases/feedback/send_feedback_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'feedback_event.dart';
part 'feedback_state.dart';

class FeedbackBloc extends Bloc<FeedbackEvent, FeedbackState> {
  final SendFeedback _sendFeedback;
  final SupabaseClient _supabaseClient;

  FeedbackBloc({
    required SendFeedback sendFeedback,
    required SupabaseClient supabaseClient,
  })  : _sendFeedback = sendFeedback,
        _supabaseClient = supabaseClient,
        super(FeedbackInitial()) {
    on<FeedbackSubmitted>(_onSubmitted);
    on<FeedbackReset>(_onReset);
  }

  Future<void> _onSubmitted(
    FeedbackSubmitted event,
    Emitter<FeedbackState> emit,
  ) async {
    emit(FeedbackLoading());

    final userId = _supabaseClient.auth.currentUser?.id ?? 'anonymous';

    final entity = FeedbackEntity(
      userId: userId,
      rating: event.rating,
      message: event.message.trim(),
      screenName: event.screenName,
      appVersion: '1.0.2',
      platform: defaultTargetPlatform.name.toLowerCase(),
      createdAt: DateTime.now(),
    );

    final result = await _sendFeedback(entity);

    result.fold(
      (failure) => emit(FeedbackFailure(failure.message)),
      (_) => emit(FeedbackSuccess()),
    );
  }

  void _onReset(FeedbackReset event, Emitter<FeedbackState> emit) {
    emit(FeedbackInitial());
  }
}
