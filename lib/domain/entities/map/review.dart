import 'package:isar/isar.dart';

part 'review.g.dart';

/// Reseña/calificación de un usuario sobre una ubicación/proveedor
@collection
class Review {
  /// ID auto-incremental de Isar
  Id id = Isar.autoIncrement;

  /// UUID de Supabase (para sincronización)
  @Index()
  String? supabaseId;

  /// ID de la ubicación/proveedor calificado
  @Index()
  String? locationId;

  /// ID del usuario que hace la reseña
  @Index()
  String? userId;

  /// Nombre del usuario (para mostrar)
  String? userName;

  /// Calificación de 1 a 5 estrellas
  @Index(type: IndexType.value)
  int rating;

  /// Comentario del usuario
  String? comment;

  /// Respuesta del dueño del negocio
  String? ownerResponse;

  /// Fecha de creación de la reseña
  DateTime? createdAt;

  /// Fecha en que el dueño respondió
  DateTime? ownerRespondedAt;

  /// Fecha de última actualización
  DateTime? updatedAt;

  Review({
    this.id = Isar.autoIncrement,
    this.supabaseId,
    this.locationId,
    this.userId,
    this.userName,
    required this.rating,
    this.comment,
    this.ownerResponse,
    this.createdAt,
    this.ownerRespondedAt,
    this.updatedAt,
  });

  /// Constructor para nueva reseña
  Review.create({
    required String locationId,
    required String userId,
    required String userName,
    required int rating,
    String? comment,
  })  : id = Isar.autoIncrement,
        supabaseId = null,
        locationId = locationId,
        userId = userId,
        userName = userName,
        rating = rating.clamp(1, 5), // Asegurar que esté entre 1-5
        comment = comment,
        ownerResponse = null,
        createdAt = DateTime.now(),
        ownerRespondedAt = null,
        updatedAt = DateTime.now();

  /// Estrellas como emojis
  /// Ejemplo: "⭐⭐⭐⭐⭐" para 5 estrellas
  String get ratingStars {
    return '⭐' * rating.clamp(1, 5);
  }

  /// Estrellas con vacías
  /// Ejemplo: "⭐⭐⭐⭐☆" para 4 estrellas
  String get ratingStarsWithEmpty {
    final filled = '⭐' * rating.clamp(1, 5);
    final empty = '☆' * (5 - rating.clamp(1, 5));
    return filled + empty;
  }

  /// Tiempo transcurrido en formato legible
  /// Ejemplo: "Hace 2 días", "Hace 3 horas"
  String get timeAgo {
    if (createdAt == null) return '';

    final diff = DateTime.now().difference(createdAt!);

    if (diff.inDays > 365) {
      final years = (diff.inDays / 365).floor();
      return 'Hace $years año${years > 1 ? 's' : ''}';
    }

    if (diff.inDays > 30) {
      final months = (diff.inDays / 30).floor();
      return 'Hace $months mes${months > 1 ? 'es' : ''}';
    }

    if (diff.inDays > 0) {
      return 'Hace ${diff.inDays} día${diff.inDays > 1 ? 's' : ''}';
    }

    if (diff.inHours > 0) {
      return 'Hace ${diff.inHours} hora${diff.inHours > 1 ? 's' : ''}';
    }

    if (diff.inMinutes > 0) {
      return 'Hace ${diff.inMinutes} minuto${diff.inMinutes > 1 ? 's' : ''}';
    }

    return 'Ahora mismo';
  }

  /// Si el dueño ya respondió
  bool get hasOwnerResponse {
    return ownerResponse != null && ownerResponse!.isNotEmpty;
  }

  /// Si la reseña tiene comentario
  bool get hasComment {
    return comment != null && comment!.isNotEmpty;
  }

  /// Validación del rating
  bool get isValidRating {
    return rating >= 1 && rating <= 5;
  }

  /// Color sugerido según el rating (hex)
  String get ratingColorHex {
    if (rating >= 4) return '#4CAF50'; // Verde - Bueno
    if (rating >= 3) return '#FF9800'; // Naranja - Regular
    return '#F44336'; // Rojo - Malo
  }

  /// Clasificación textual del rating
  String get ratingLabel {
    switch (rating) {
      case 5:
        return 'Excelente';
      case 4:
        return 'Muy bueno';
      case 3:
        return 'Bueno';
      case 2:
        return 'Regular';
      case 1:
        return 'Malo';
      default:
        return 'Sin calificación';
    }
  }

  Review copyWith({
    Id? id,
    String? supabaseId,
    String? locationId,
    String? userId,
    String? userName,
    int? rating,
    String? comment,
    String? ownerResponse,
    DateTime? createdAt,
    DateTime? ownerRespondedAt,
    DateTime? updatedAt,
  }) {
    return Review(
      id: id ?? this.id,
      supabaseId: supabaseId ?? this.supabaseId,
      locationId: locationId ?? this.locationId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      ownerResponse: ownerResponse ?? this.ownerResponse,
      createdAt: createdAt ?? this.createdAt,
      ownerRespondedAt: ownerRespondedAt ?? this.ownerRespondedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Review(id: $id, locationId: $locationId, rating: $rating, hasComment: $hasComment)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Review &&
        other.supabaseId == supabaseId &&
        other.locationId == locationId &&
        other.userId == userId;
  }

  @override
  int get hashCode => Object.hash(supabaseId, locationId, userId);
}

/// Helper para estadísticas de reseñas
class ReviewStats {
  final int totalReviews;
  final double averageRating;
  final Map<int, int> ratingDistribution; // {5: 10, 4: 5, 3: 2, 2: 1, 1: 0}

  ReviewStats({
    required this.totalReviews,
    required this.averageRating,
    required this.ratingDistribution,
  });

  /// Calcula estadísticas desde una lista de reseñas
  factory ReviewStats.fromReviews(List<Review> reviews) {
    if (reviews.isEmpty) {
      return ReviewStats(
        totalReviews: 0,
        averageRating: 0.0,
        ratingDistribution: {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
      );
    }

    final distribution = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    var totalRating = 0;

    for (var review in reviews) {
      final rating = review.rating.clamp(1, 5);
      distribution[rating] = (distribution[rating] ?? 0) + 1;
      totalRating += rating;
    }

    return ReviewStats(
      totalReviews: reviews.length,
      averageRating: totalRating / reviews.length,
      ratingDistribution: distribution,
    );
  }

  /// Porcentaje de cada rating
  Map<int, double> get ratingPercentages {
    if (totalReviews == 0) {
      return {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    }

    return ratingDistribution.map(
      (rating, count) => MapEntry(rating, (count / totalReviews) * 100),
    );
  }

  /// Rating formateado con 1 decimal
  String get formattedRating {
    return averageRating.toStringAsFixed(1);
  }

  /// Si tiene suficientes reseñas para ser confiable (ej: mínimo 5)
  bool get isReliable {
    return totalReviews >= 5;
  }
}
