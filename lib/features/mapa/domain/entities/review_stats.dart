/// Estadísticas de reseñas para una ubicación
class ReviewStats {
  final int totalReviews;
  final double averageRating;
  final int rating5Count;
  final int rating4Count;
  final int rating3Count;
  final int rating2Count;
  final int rating1Count;
  final int hasResponseCount;

  const ReviewStats({
    required this.totalReviews,
    required this.averageRating,
    required this.rating5Count,
    required this.rating4Count,
    required this.rating3Count,
    required this.rating2Count,
    required this.rating1Count,
    required this.hasResponseCount,
  });

  /// Porcentaje de cada calificación
  double get rating5Percentage =>
      totalReviews > 0 ? (rating5Count / totalReviews) * 100 : 0;
  double get rating4Percentage =>
      totalReviews > 0 ? (rating4Count / totalReviews) * 100 : 0;
  double get rating3Percentage =>
      totalReviews > 0 ? (rating3Count / totalReviews) * 100 : 0;
  double get rating2Percentage =>
      totalReviews > 0 ? (rating2Count / totalReviews) * 100 : 0;
  double get rating1Percentage =>
      totalReviews > 0 ? (rating1Count / totalReviews) * 100 : 0;

  /// Porcentaje de reseñas con respuesta
  double get responseRate =>
      totalReviews > 0 ? (hasResponseCount / totalReviews) * 100 : 0;

  /// Tiene suficientes reseñas para mostrar estadísticas
  bool get hasEnoughData => totalReviews >= 3;

  /// Rating formateado
  String get formattedRating => averageRating.toStringAsFixed(1);

  /// Distribución de ratings como lista
  List<RatingDistribution> get distribution => [
        RatingDistribution(
          stars: 5,
          count: rating5Count,
          percentage: rating5Percentage,
        ),
        RatingDistribution(
          stars: 4,
          count: rating4Count,
          percentage: rating4Percentage,
        ),
        RatingDistribution(
          stars: 3,
          count: rating3Count,
          percentage: rating3Percentage,
        ),
        RatingDistribution(
          stars: 2,
          count: rating2Count,
          percentage: rating2Percentage,
        ),
        RatingDistribution(
          stars: 1,
          count: rating1Count,
          percentage: rating1Percentage,
        ),
      ];

  /// ReviewStats vacío (sin reseñas)
  factory ReviewStats.empty() {
    return const ReviewStats(
      totalReviews: 0,
      averageRating: 0.0,
      rating5Count: 0,
      rating4Count: 0,
      rating3Count: 0,
      rating2Count: 0,
      rating1Count: 0,
      hasResponseCount: 0,
    );
  }

  /// Desde Map (desde Supabase)
  factory ReviewStats.fromMap(Map<String, dynamic> map) {
    return ReviewStats(
      totalReviews: (map['total_reviews'] as int?) ?? 0,
      averageRating: ((map['average_rating'] as num?)?.toDouble()) ?? 0.0,
      rating5Count: (map['rating_5_count'] as int?) ?? 0,
      rating4Count: (map['rating_4_count'] as int?) ?? 0,
      rating3Count: (map['rating_3_count'] as int?) ?? 0,
      rating2Count: (map['rating_2_count'] as int?) ?? 0,
      rating1Count: (map['rating_1_count'] as int?) ?? 0,
      hasResponseCount: (map['has_response_count'] as int?) ?? 0,
    );
  }

  /// A Map
  Map<String, dynamic> toMap() {
    return {
      'total_reviews': totalReviews,
      'average_rating': averageRating,
      'rating_5_count': rating5Count,
      'rating_4_count': rating4Count,
      'rating_3_count': rating3Count,
      'rating_2_count': rating2Count,
      'rating_1_count': rating1Count,
      'has_response_count': hasResponseCount,
    };
  }

  @override
  String toString() {
    return 'ReviewStats(total: $totalReviews, avg: $formattedRating, 5★: $rating5Count, 4★: $rating4Count, 3★: $rating3Count, 2★: $rating2Count, 1★: $rating1Count)';
  }
}

/// Distribución de una calificación específica
class RatingDistribution {
  final int stars;
  final int count;
  final double percentage;

  const RatingDistribution({
    required this.stars,
    required this.count,
    required this.percentage,
  });

  String get starsLabel => '$stars★';
  String get percentageLabel => '${percentage.toStringAsFixed(0)}%';
}
