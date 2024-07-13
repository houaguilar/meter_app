class Failure {
  final String message;
  final FailureType type;

  Failure({
    required this.message,
    this.type = FailureType.general,
  });
}

enum FailureType {
  general,
  duplicateName,
  unknown
}