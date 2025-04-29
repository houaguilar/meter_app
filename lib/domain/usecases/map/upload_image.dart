
import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../../../config/constants/error/failures.dart';
import '../../../config/usecase/usecase.dart';
import '../../repositories/map/location_repository.dart';

class UploadImage implements UseCase<String, File> {
  final LocationRepository repository;

  UploadImage(this.repository);

  @override
  Future<Either<Failure, String>> call(File image) async {
    return await repository.uploadImage(image);
  }
}