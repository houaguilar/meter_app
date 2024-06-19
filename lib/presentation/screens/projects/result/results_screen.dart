import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/entities.dart';
import '../../../blocs/projects/metrados/result/result_bloc.dart';

class ResultsScreen extends StatelessWidget {
  final String metradoId;

  const ResultsScreen({required this.metradoId, super.key});

  @override
  Widget build(BuildContext context) {
    context.read<ResultBloc>().add(LoadResultsEvent(metradoId: metradoId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados Guardados'),
      ),
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
            return double.parse(result.largo) * double.parse(result.altura);
          }
          return ListTile(
            title: Text(result.description),
            trailing: Text('${area().toString()} (m2)'),
          );
        } else if (result is Bloqueta) {
          double area() {
            return double.parse(result.largo) * double.parse(result.altura);
          }
          return ListTile(
            title: Text(result.description),
            trailing: Text('${area().toString()} (m2)'),
          );
        } else if (result is Piso) {
          double volumen() {
            return double.parse(result.largo) * double.parse(result.altura) * double.parse(result.ancho);
          }
          return ListTile(
            title: Text(result.description),
            subtitle: Text('Altura: ${result.altura}'),
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
            _buildMaterialDetails(results),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialDetails(List<dynamic> results) {
    // Aquí debes adaptar para mostrar detalles específicos de materiales
    // Asumiré que tienes una forma de mapear estos a los datos que necesitas mostrar
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMaterialRow('Arena Gruesa', 'm3', '0.32'),
        _buildMaterialRow('Cemento', 'bls', '3.0'),
        _buildMaterialRow('Ladrillo', 'und', '436.56'),
      ],
    );
  }

  Widget _buildMaterialRow(String material, String unit, String quantity) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(material, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(unit),
          Text(quantity),
        ],
      ),
    );
  }
}
