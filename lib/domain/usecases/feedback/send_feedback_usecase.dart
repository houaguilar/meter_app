import 'package:fpdart/fpdart.dart';
import 'package:meter_app/config/constants/error/failures.dart';
import 'package:meter_app/config/usecase/usecase.dart';
import 'package:meter_app/domain/entities/feedback/feedback_entity.dart';
import 'package:meter_app/domain/repositories/feedback/feedback_repository.dart';

class SendFeedback implements UseCase<void, FeedbackEntity> {
  final FeedbackRepository repository;

  SendFeedback(this.repository);

  @override
  Future<Either<Failure, void>> call(FeedbackEntity params) =>
      repository.sendFeedback(params);
}
