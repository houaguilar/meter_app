import 'package:isar/isar.dart';

part 'business_hours.g.dart';

/// Horario de atención de un día específico
@embedded
class BusinessHours {
  /// Hora de apertura en formato "HH:mm" (ej: "08:00")
  String? open;

  /// Hora de cierre en formato "HH:mm" (ej: "18:00")
  String? close;

  /// Si está cerrado todo el día
  bool closed;

  BusinessHours({
    this.open,
    this.close,
    this.closed = false,
  });

  /// Constructor para día cerrado
  BusinessHours.closed()
      : open = null,
        close = null,
        closed = true;

  /// Constructor desde JSON (JSONB de Supabase)
  factory BusinessHours.fromJson(Map<String, dynamic> json) {
    return BusinessHours(
      open: json['open'] as String?,
      close: json['close'] as String?,
      closed: json['closed'] as bool? ?? false,
    );
  }

  /// Convierte a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      'open': open,
      'close': close,
      'closed': closed,
    };
  }

  /// Texto para mostrar en UI
  /// Ejemplos: "08:00 - 18:00", "Cerrado"
  String get displayTime {
    if (closed || open == null || close == null) {
      return 'Cerrado';
    }
    return '$open - $close';
  }

  /// Si está abierto en este momento
  bool get isOpenNow {
    if (closed || open == null || close == null) return false;

    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return currentTime.compareTo(open!) >= 0 && currentTime.compareTo(close!) <= 0;
  }

  /// Valida si el horario es correcto
  bool get isValid {
    if (closed) return true;
    if (open == null || close == null) return false;

    // Validar formato HH:mm
    final timeRegex = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');
    if (!timeRegex.hasMatch(open!) || !timeRegex.hasMatch(close!)) {
      return false;
    }

    // Validar que cierre sea después de apertura
    return close!.compareTo(open!) > 0;
  }

  BusinessHours copyWith({
    String? open,
    String? close,
    bool? closed,
  }) {
    return BusinessHours(
      open: open ?? this.open,
      close: close ?? this.close,
      closed: closed ?? this.closed,
    );
  }

  @override
  String toString() {
    return 'BusinessHours(open: $open, close: $close, closed: $closed)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BusinessHours &&
        other.open == open &&
        other.close == close &&
        other.closed == closed;
  }

  @override
  int get hashCode => Object.hash(open, close, closed);
}

/// Helper para manejar horarios de toda la semana
class WeeklyBusinessHours {
  final Map<String, BusinessHours> hours;

  WeeklyBusinessHours(this.hours);

  /// Días de la semana en español
  static const weekDays = [
    'lunes',
    'martes',
    'miercoles',
    'jueves',
    'viernes',
    'sabado',
    'domingo',
  ];

  /// Constructor con horarios por defecto (cerrado todos los días)
  factory WeeklyBusinessHours.empty() {
    return WeeklyBusinessHours({
      for (var day in weekDays) day: BusinessHours.closed(),
    });
  }

  /// Constructor con el mismo horario para todos los días
  factory WeeklyBusinessHours.sameForAll(BusinessHours hours) {
    return WeeklyBusinessHours({
      for (var day in weekDays) day: hours,
    });
  }

  /// Constructor desde JSON (JSONB de Supabase)
  factory WeeklyBusinessHours.fromJson(Map<String, dynamic> json) {
    return WeeklyBusinessHours({
      for (var entry in json.entries)
        entry.key: BusinessHours.fromJson(entry.value as Map<String, dynamic>),
    });
  }

  /// Convierte a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      for (var entry in hours.entries) entry.key: entry.value.toJson(),
    };
  }

  /// Obtiene el horario para hoy
  BusinessHours? get today {
    final now = DateTime.now();
    final dayIndex = now.weekday - 1; // 1 (lunes) -> 0
    if (dayIndex < 0 || dayIndex >= weekDays.length) return null;
    return hours[weekDays[dayIndex]];
  }

  /// Si está abierto ahora
  bool get isOpenNow {
    return today?.isOpenNow ?? false;
  }
}
