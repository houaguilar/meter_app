class TipoLadrilloModel {
  String imageAsset;
  String title;
  String location;

  TipoLadrilloModel({
    required this.imageAsset,
    required this.title,
    required this.location,
  });
  static List<TipoLadrilloModel> generateTipoLadrillo() {
    return [
      TipoLadrilloModel(
        imageAsset: 'assets/images/kingkong_piramide.png',
        title: 'Kingkong',
        location: 'tutorial-ladrillo',
      ),
      TipoLadrilloModel(
        imageAsset: 'assets/images/pandereta_piramide.png',
        title: 'Pandereta',
        location: 'tutorial-ladrillo',
      ),
      TipoLadrilloModel(
        imageAsset: 'assets/images/tabicon_piramide.png',
        title: 'Tabicon',
        location: 'tutorial-ladrillo',
      ),
    ];
  }
}