class FeedbackEntity {
  final String userId;
  final int rating;
  final String message;
  final String screenName;
  final String appVersion;
  final String platform;
  final DateTime createdAt;

  const FeedbackEntity({
    required this.userId,
    required this.rating,
    required this.message,
    required this.screenName,
    required this.appVersion,
    required this.platform,
    required this.createdAt,
  });
}
