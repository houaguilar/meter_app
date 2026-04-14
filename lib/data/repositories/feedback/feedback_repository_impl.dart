import 'package:fpdart/fpdart.dart';
import 'package:meter_app/config/constants/error/exceptions.dart';
import 'package:meter_app/config/constants/error/failures.dart';
import 'package:meter_app/config/network/connection_checker.dart';
import 'package:meter_app/data/datasources/feedback/feedback_remote_datasource.dart';
import 'package:meter_app/data/models/feedback/feedback_model.dart';
import 'package:meter_app/domain/entities/feedback/feedback_entity.dart';
import 'package:meter_app/domain/repositories/feedback/feedback_repository.dart';

class FeedbackRepositoryImpl implements FeedbackRepository {
  final FeedbackRemoteDataSource remoteDataSource;
  final ConnectionChecker connectionChecker;

  FeedbackRepositoryImpl(this.remoteDataSource, this.connectionChecker);

  @override
  Future<Either<Failure, void>> sendFeedback(FeedbackEntity feedback) async {
    if (!await connectionChecker.isConnected) {
      return left(Failure(
        message: 'Sin conexión a internet. Intenta de nuevo.',
        type: FailureType.network,
      ));
    }
    try {
      await remoteDataSource.sendFeedback(FeedbackModel.fromEntity(feedback));
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(message: e.message, type: FailureType.server));
    }
  }
}
