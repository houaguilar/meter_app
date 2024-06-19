import 'package:flutter/material.dart';

class HomeListItem {
  String imageAsset;
  String title;
  String location;
  Color bgColor;

  HomeListItem({
    required this.imageAsset,
    required this.title,
    required this.location,
    required this.bgColor,
  });
 /* static List<HomeListItem> generateListHome() {
    return [
      HomeListItem(
        imageAsset: 'assets/images/perfil.png',
        title: 'Muro',
        location: 'muro',
        bgColor: getRandomColor(),
      ),
      HomeListItem(
        imageAsset: 'assets/images/perfil.png',
        title: 'Columna',
        location: 'columna',
        bgColor: getRandomColor(),
      ),
      HomeListItem(
        imageAsset: 'assets/images/perfil.png',
        title: 'Piso',
        location: 'pisos',
        bgColor: getRandomColor(),
      ),
      HomeListItem(
        imageAsset: 'assets/images/perfil.png',
        title: 'Losa',
        location: 'losas',
        bgColor: getRandomColor(),
      ),
    ];
  }*/
}