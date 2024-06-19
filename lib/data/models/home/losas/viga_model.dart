class VigaModel {
  final String id;
  final String description;
  final String largo;
  final String ancho;
  final String altura;

  VigaModel({
    required this.id,
    required this.description,
    required this.largo,
    required this.ancho,
    required this.altura
  });

  VigaModel copyWith({
    String? id,
    String? description,
    String? largo,
    String? ancho,
    String? altura,
  }) => VigaModel(
    id: id ?? this.id,
    description: description ?? this.description,
    largo: largo ?? this.largo,
    ancho: ancho ?? this.ancho,
    altura: altura ?? this.altura,
  );
}