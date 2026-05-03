import 'package:fpdart/fpdart.dart';

import 'package:meter_app/core/constants/error/failures.dart';

abstract interface class UseCase<SuccessType, Params> {
  Future<Either<Failure, SuccessType>> call(Params params);
}

class NoParams {}