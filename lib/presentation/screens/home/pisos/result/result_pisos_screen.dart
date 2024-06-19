
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../config/constants/colors.dart';
import '../../../../../data/models/models.dart';
import '../../../../providers/providers.dart';
import '../../../widgets/widgets.dart';

class ResultPisosScreen extends ConsumerWidget {
  const ResultPisosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WillPopScope(
      onWillPop: () async {
        ref.read(pisosResultProvider.notifier).clearList();
        return true;
      },
      child: Scaffold(
        appBar: const AppBarWidget(titleAppBar: 'Resultados',),
        body: const _ResultPisosScreenView(),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              tooltip: 'Compartir',
              onPressed: () async {
                  await Share.share(_shareContent(ref));
              },
              heroTag: "btnShare",
              child: const Icon(Icons.ios_share_rounded),
            ),
            const SizedBox(height: 8,),
            FloatingActionButton(
              onPressed: () => context.pushNamed('save-piso'),
              heroTag: "btnSave",
              child: const Icon(Icons.add_box_rounded),
            ),
            const SizedBox(height: 80,)
          ],
        ),
      ),
    );
  }

  void _showToast(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: const Text('Se guardó exitosamente'),
        action: SnackBarAction(label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  String _shareContent(WidgetRef ref) {
    final listaPisos = ref.watch(pisosResultProvider);

    String cantidadPiedraChancadaToString = cantidadPiedraChancada(listaPisos).toStringAsFixed(2);
    String cantidadArenaToString = cantidadArenaGruesa(listaPisos).toStringAsFixed(2);
    String cantidadCementoToString = cantidadCementoPisos(listaPisos).ceilToDouble().toString();

    String datosMetrado = 'DATOS METRADO';
    String listaMateriales = 'LISTA DE MATERIALES';

    if (listaPisos.isNotEmpty) {
      final datosLadrillo = ref.watch(datosSharePisosProvider);
      final shareText = '$datosMetrado \n$datosLadrillo \n-------------\n$listaMateriales \n*Arena gruesa: $cantidadArenaToString m3 \n*Cemento: $cantidadCementoToString bls \n${listaPisos.first.tipo == 'contrapiso' ? '*Piedra chancada: $cantidadPiedraChancadaToString m3' : ''}';
      return shareText;
    } else {
      return 'Error';
    }
  }
}

class _ResultPisosScreenView extends ConsumerWidget {
  const _ResultPisosScreenView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final listaPisos = ref.watch(pisosResultProvider);
    String cantidadPiedraChancadaToString = cantidadPiedraChancada(listaPisos).toStringAsFixed(2);
    String cantidadArenaToString = cantidadArenaGruesa(listaPisos).toStringAsFixed(2);
    String cantidadCementoToString = cantidadCementoPisos(listaPisos).ceilToDouble().toString();

    return Column(
      children: [
        const Expanded(
          child: _PisosContainer(),
        ),
        MaterialButton(
          onPressed: () {
            ref.watch(cantidadArenaPisosProvider);
            ref.watch(cantidadCementoPisosProvider);
            ref.watch(cantidadPiedraChancadaProvider);

            if (listaPisos.first.tipo == 'contrapiso') {
              ref.read(cantidadArenaPisosProvider.notifier).arena(cantidadArenaToString);
              ref.read(cantidadCementoPisosProvider.notifier).cemento(cantidadCementoToString);
            } else {
              ref.read(cantidadArenaPisosProvider.notifier).arena(cantidadArenaToString);
              ref.read(cantidadCementoPisosProvider.notifier).cemento(cantidadCementoToString);
              ref.read(cantidadPiedraChancadaProvider.notifier).piedra(cantidadPiedraChancadaToString);
            }
            context.goNamed('pisos-pdf');
          },
          color: AppColors.orange,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          height: 50,
          minWidth: 200,
          child: const Text("Generar PDF",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold)
          ),
        ),
        const SizedBox(height: 20,)
      ],
    );
  }
}

class _PisosContainer extends ConsumerWidget {
  const _PisosContainer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(pisosResultProvider);
    return _buildPisosContainer(context, results);
  }

  Widget _buildPisosContainer(BuildContext context, List<Piso> results) {

    double volume(int index) {
      return double.parse(results[index].largo) * double.parse(results[index].altura) * double.parse(results[index].ancho);
    }

    String cantidadPiedraChancadaToString = cantidadPiedraChancada(results).toStringAsFixed(2);
    String cantidadArenaToString = cantidadArenaGruesa(results).toStringAsFixed(2);
    String cantidadCementoToString = cantidadCementoPisos(results).ceilToDouble().toString();

    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          const Text('Datos del Metrado', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
          const CommonContentResults(descripcion: '', unidad: 'UNIDAD', cantidad: 'CANTIDAD', sizeText: 16, weightText: FontWeight.w500),
          ListView.builder(
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return CommonContentResults(descripcion: results[index].description, unidad: 'm3', cantidad: volume(index).toString(), sizeText: 14, weightText: FontWeight.normal);
            },
            itemCount: results.length,
          ),
          const SizedBox(height: 20,),
          const Text('Lista de Materiales', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
          const CommonContentResults(descripcion: '', unidad: 'UNIDAD', cantidad: 'CANTIDAD', sizeText: 16, weightText: FontWeight.w500),
          CommonContentResults(descripcion: 'ARENA GRUESA', unidad: 'm3', cantidad: cantidadArenaToString, sizeText: 14, weightText: FontWeight.normal),
          CommonContentResults(descripcion: 'CEMENTO', unidad: 'bls', cantidad: cantidadCementoToString, sizeText: 14, weightText: FontWeight.normal),
          Visibility(
            visible: results.first.tipo != 'contrapiso',
              child: CommonContentResults(descripcion: 'PIEDRA CHANCADA', unidad: 'm3', cantidad: cantidadPiedraChancadaToString, sizeText: 14, weightText: FontWeight.normal)
          ),
        ],
      ),
    );
  }
}

double calcularCantidadPiedraChancada(String tipoPiso, double largo, double altura, double ancho){
  switch (tipoPiso) {
    case 'falso':
      return largo * altura * ancho * 0.72 * 0.05;
    default:
      return 0;
  }
}

double calcularCantidadArenaGruesa(String tipoPiso, double largo, double altura, double ancho) {
  switch (tipoPiso) {
    case 'falso':
      return largo * altura * ancho * 0.72 * 0.05;
    case 'contrapiso':
      return largo * altura * ancho * 1 * 0.05;
    default:
      return 0;
  }
}

double calcularCantidadCementoPisos(String tipoPiso, double largo, double altura, double ancho) {
  switch (tipoPiso) {
    case 'falso':
      return largo * altura * ancho * 7.06 * 0.05;
    case 'contrapiso':
      return largo * altura * ancho * 7.4 * 0.05;
    default:
      return 0;
  }
}

double cantidadPiedraChancada(List<Piso> results) {
  double sumaDePiedras = 0.0;
  for (Piso piso in results) {
    double largo = double.parse(piso.largo);
    double altura = double.parse(piso.altura);
    double ancho = double.parse(piso.largo);
    sumaDePiedras += calcularCantidadPiedraChancada(piso.tipo, largo, altura, ancho);
  }
  return sumaDePiedras;
}

double cantidadArenaGruesa(List<Piso> results) {
  double sumaDeArena = 0.0;
  for (Piso piso in results) {
    double largo = double.parse(piso.largo);
    double altura = double.parse(piso.altura);
    double ancho = double.parse(piso.largo);
    sumaDeArena += calcularCantidadArenaGruesa(piso.tipo, largo, altura, ancho);
  }
  return sumaDeArena;
}

double cantidadCementoPisos(List<Piso> results) {
  double sumaDeCemento = 0.0;
  for (Piso piso in results) {
    double largo = double.parse(piso.largo);
    double altura = double.parse(piso.altura);
    double ancho = double.parse(piso.largo);
    sumaDeCemento += calcularCantidadCementoPisos(piso.tipo, largo, altura, ancho);
  }
  return sumaDeCemento;
}