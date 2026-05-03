
import 'dart:io';

import 'package:fpdart/fpdart.dart';

import 'package:meter_app/core/constants/error/failures.dart';
import 'package:meter_app/core/usecase/usecase.dart';
import 'package:meter_app/features/mapa/domain/repositories/location_repository.dart';

class UploadImage implements UseCase<String, File> {
  final LocationRepository repository;

  UploadImage(this.repository);

  @override
  Future<Either<Failure, String>> call(File image) async {
    return await repository.uploadImage(image);
  }
}