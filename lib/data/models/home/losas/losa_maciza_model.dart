class LosaMacizaModel {
  final String id;
  final String description;
  final String largo;
  final String ancho;
  final String peralte;

  LosaMacizaModel({
    required this.id,
    required this.description,
    required this.largo,
    required this.ancho,
    required this.peralte
  });

  LosaMacizaModel copyWith({
    String? id,
    String? description,
    String? largo,
    String? ancho,
    String? peralte,
  }) => LosaMacizaModel(
    id: id ?? this.id,
    description: description ?? this.description,
    largo: largo ?? this.largo,
    ancho: ancho ?? this.ancho,
    peralte: peralte ?? this.peralte,
  );
}