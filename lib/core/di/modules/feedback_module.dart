import 'package:get_it/get_it.dart';
import 'package:meter_app/core/services/review_service.dart';
import 'package:meter_app/features/feedback/data/datasources/feedback_remote_datasource.dart';
import 'package:meter_app/features/feedback/data/repositories/feedback_repository_impl.dart';
import 'package:meter_app/features/feedback/domain/repositories/feedback_repository.dart';
import 'package:meter_app/features/feedback/domain/usecases/send_feedback_usecase.dart';
import 'package:meter_app/features/feedback/presentation/blocs/feedback_bloc.dart';

void registerFeedbackModule(GetIt sl) {
  // ==================== SERVICES ====================
  sl.registerLazySingleton<ReviewService>(
    () => ReviewService(sl()),
  );

  // ==================== DATASOURCES ====================
  sl.registerFactory<FeedbackRemoteDataSource>(
    () => FeedbackRemoteDataSourceImpl(sl()),
  );

  // ==================== REPOSITORIES ====================
  sl.registerFactory<FeedbackRepository>(
    () => FeedbackRepositoryImpl(sl(), sl()),
  );

  // ==================== USE CASES ====================
  sl.registerFactory(() => SendFeedback(sl<FeedbackRepository>()));

  // ==================== BLOCS ====================
  sl.registerLazySingleton(
    () => FeedbackBloc(
      sendFeedback: sl<SendFeedback>(),
      supabaseClient: sl(),
    ),
  );
}
