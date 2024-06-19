class TipoBloquetaModel {
  String imageAsset;
  String title;
  String location;

  TipoBloquetaModel({
    required this.imageAsset,
    required this.title,
    required this.location,
  });
  static List<TipoBloquetaModel> generateTipoBloqueta() {
    return [
      TipoBloquetaModel(
        imageAsset: 'assets/images/tabicon_piramide.png',
        title: 'P7',
        location: 'bloqueta1',
      ),
      TipoBloquetaModel(
        imageAsset: 'assets/images/tabicon_piramide.png',
        title: 'P10',
        location: 'bloqueta1',
      ),
      TipoBloquetaModel(
        imageAsset: 'assets/images/tabicon_piramide.png',
        title: 'P12',
        location: 'bloqueta1',
      ),
    ];
  }
}