import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meter_app/presentation/widgets/app_bar/app_bar_projects_widget.dart';

import '../../../../domain/entities/entities.dart';
import '../../../blocs/projects/metrados/result/result_bloc.dart';

class ResultScreen extends StatelessWidget {
  final String metradoId;

  const ResultScreen({required this.metradoId, super.key});

  @override
  Widget build(BuildContext context) {
    context.read<ResultBloc>().add(LoadResultsEvent(metradoId: metradoId));

    return Scaffold(
      appBar: const AppBarProjectsWidget(titleAppBar: 'Resultados Guardados'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<ResultBloc, ResultState>(
          builder: (context, state) {
            if (state is ResultLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ResultSuccess) {
              return _buildResults(context, state.results);
            } else if (state is ResultFailure) {
              return Center(child: Text('Error: ${state.message}'));
            } else {
              return const Center(child: Text('No hay resultados disponibles'));
            }
          },
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context, List<dynamic> results) {
    if (results.isEmpty) {
      return const Center(child: Text('No hay resultados disponibles'));
    }

    return Column(
      children: [
        _buildMetradoCard(context, results),
        const SizedBox(height: 16.0),
        _buildMaterialListCard(context, results),
      ],
    );
  }

  Widget _buildMetradoCard(BuildContext context, List<dynamic> results) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Datos del Metrado',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8.0),
            _buildMetradoDetails(context, results),
          ],
        ),
      ),
    );
  }

  Widget _buildMetradoDetails(BuildContext context, List<dynamic> results) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: results.map((result) {
        if (result is Ladrillo) {
          double area() {
            // Si largo o altura son nulos, retornamos 0.0 como valor por defecto
            final largo = double.tryParse(result.largo ?? '') ?? 0.0;
            final altura = double.tryParse(result.altura ?? '') ?? 0.0;
            return largo * altura;
          }
          return ListTile(
            title: Text(result.description),
            trailing: Text('${area().toString()} (m2)'),
          );
        } else if (result is Bloqueta) {
          double area() {
            return double.parse(result.largo ?? '') * double.parse(result.altura ?? '');
          }
          return ListTile(
            title: Text(result.description),
            trailing: Text('${area().toString()} (m2)'),
          );
        } else if (result is Piso) {
          double volumen() {
         //   return double.parse(result.largo) * double.parse(result.altura) * double.parse(result.ancho);
            return 0.0;
          }
          return ListTile(
            title: Text(result.description),
            subtitle: Text('Altura: ${result.ancho}'),
            trailing: Text('${volumen().toString()} (m3)'),
          );
        } else {
          return const ListTile(
            title: Text('Resultado desconocido'),
          );
        }
      }).toList(),
    );
  }

  Widget _buildMaterialListCard(BuildContext context, List<dynamic> results) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lista de Materiales',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8.0),
            _buildMaterialDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialDetails() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(3), // Controla el ancho de la primera columna
        1: FlexColumnWidth(1), // Controla el ancho de la segunda columna
        2: FlexColumnWidth(1), // Controla el ancho de la tercera columna
      },
      children: [
        _buildTableHeader(),
        _buildMaterialRow('Arena Gruesa', 'm3', '0.32'),
        _buildMaterialRow('Cemento', 'bls', '3.0'),
        _buildMaterialRow('Ladrillo', 'und', '436.56'),
      ],
    );
  }

  TableRow _buildTableHeader() {
    return const TableRow(
      decoration: BoxDecoration(
        color: Colors.grey,
      ),
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Descripción',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Unidad',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Cantidad',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ],
    );
  }

  TableRow _buildMaterialRow(String material, String unit, String quantity) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(material),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(unit),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(quantity),
        ),
      ],
    );
  }
}
