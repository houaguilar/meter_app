import 'package:fpdart/fpdart.dart';
import 'package:meter_app/config/constants/error/failures.dart';
import 'package:meter_app/domain/entities/feedback/feedback_entity.dart';

abstract interface class FeedbackRepository {
  Future<Either<Failure, void>> sendFeedback(FeedbackEntity feedback);
}
