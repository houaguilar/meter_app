import 'package:meter_app/domain/entities/feedback/feedback_entity.dart';

class FeedbackModel {
  final String userId;
  final int rating;
  final String message;
  final String screenName;
  final String appVersion;
  final String platform;
  final DateTime createdAt;

  const FeedbackModel({
    required this.userId,
    required this.rating,
    required this.message,
    required this.screenName,
    required this.appVersion,
    required this.platform,
    required this.createdAt,
  });

  factory FeedbackModel.fromEntity(FeedbackEntity entity) => FeedbackModel(
        userId: entity.userId,
        rating: entity.rating,
        message: entity.message,
        screenName: entity.screenName,
        appVersion: entity.appVersion,
        platform: entity.platform,
        createdAt: entity.createdAt,
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'rating': rating,
        'message': message,
        'screen_name': screenName,
        'app_version': appVersion,
        'platform': platform,
        'created_at': createdAt.toIso8601String(),
      };
}
