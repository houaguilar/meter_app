class EscaleraModel {
  final String id;
  final String description;
  final String largo;
  final String ancho;
  final String espesor;
  final String numeroPasos;
  final String pasos;
  final String contrapaso;

  EscaleraModel({
    required this.id,
    required this.description,
    required this.largo,
    required this.ancho,
    required this.espesor,
    required this.numeroPasos,
    required this.pasos,
    required this.contrapaso,
  });

  EscaleraModel copyWith({
    String? id,
    String? description,
    String? largo,
    String? ancho,
    String? espesor,
    String? numeroPasos,
    String? pasos,
    String? contrapaso,
  }) => EscaleraModel(
    id: id ?? this.id,
    description: description ?? this.description,
    largo: largo ?? this.largo,
    ancho: ancho ?? this.ancho,
    espesor: espesor ?? this.espesor,
    numeroPasos: numeroPasos ?? this.numeroPasos,
    pasos: pasos ?? this.pasos,
    contrapaso: contrapaso ?? this.contrapaso,
  );
}