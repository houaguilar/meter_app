import 'package:get_it/get_it.dart';
import 'package:meter_app/config/services/review_service.dart';
import 'package:meter_app/data/datasources/feedback/feedback_remote_datasource.dart';
import 'package:meter_app/data/repositories/feedback/feedback_repository_impl.dart';
import 'package:meter_app/domain/repositories/feedback/feedback_repository.dart';
import 'package:meter_app/domain/usecases/feedback/send_feedback_usecase.dart';
import 'package:meter_app/presentation/blocs/feedback/feedback_bloc.dart';

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
