import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animations/animations.dart'; // Importar el paquete de animaciones
import 'package:meter_app/config/constants/constants.dart';
import '../../../../domain/entities/projects/metrado/metrado.dart';
import '../../../blocs/projects/metrados/metrados_bloc.dart';
import '../result/results_screen.dart';

class MetradosScreen extends StatelessWidget {
  final int projectId;
  final String projectName;

  const MetradosScreen({required this.projectId, required this.projectName, super.key});

  @override
  Widget build(BuildContext context) {
    context.read<MetradosBloc>().add(LoadMetradosEvent(projectId: projectId));

    return Scaffold(
      appBar: AppBar(title: Text('Poyecto - $projectName')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: BlocBuilder<MetradosBloc, MetradosState>(
                builder: (context, state) {
                  if (state is MetradoLoading) {
                    return Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor));
                  } else if (state is MetradoSuccess) {
                    return _buildMetradosList(context, state);
                  } else if (state is MetradoFailure) {
                    return _buildErrorContent(context, state.message);
                  } else {
                    return const Center(child: Text('Ocurrió un error inesperado'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetradosList(BuildContext context, MetradoSuccess state) {
    return state.metrados.isEmpty
        ? const Center(child: Text('No hay metrados disponibles'))
        : ListView.separated(
      itemCount: state.metrados.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final metrado = state.metrados[index];
        return Dismissible(
          key: Key(metrado.id.toString()),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            context.read<MetradosBloc>().add(DeleteMetradoEvent(metrado: metrado));
          },
          confirmDismiss: (direction) async {
            return await _showDeleteConfirmationDialog(context);
          },
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: OpenContainer(
            closedElevation: 0,
            transitionType: ContainerTransitionType.fade,
            closedBuilder: (context, openContainer) => ListTile(
              leading: const Icon(Icons.receipt_rounded),
              title: Text(
                metrado.name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryMetraShop,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditMetradoBottomSheet(context, metrado),
              ),
              onTap: openContainer,
            ),
            openBuilder: (context, _) => ResultsScreen(metradoId: metrado.id.toString()),
          ),
        );
      },
    );
  }

  Widget _buildErrorContent(BuildContext context, String message) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Error: $message', textAlign: TextAlign.center),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => context.read<MetradosBloc>().add(LoadMetradosEvent(projectId: projectId)),
          child: const Text('Reintentar'),
        ),
      ],
    );
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar Metrado', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este metrado?\nSe eliminarán también los resultados correspondientes.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showEditMetradoBottomSheet(BuildContext context, Metrado metrado) {
    final TextEditingController controller = TextEditingController(text: metrado.name);
    showModal(
      context: context,
      builder: (context) {
        return FadeScaleTransition(
          animation: CurvedAnimation(
            parent: ModalRoute.of(context)!.animation!,
            curve: Curves.easeInOut,
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(labelText: 'Editar nombre del metrado', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    final newName = controller.text.trim();
                    if (newName.isNotEmpty) {
                      context.read<MetradosBloc>().add(EditMetradoEvent(metrado: metrado.copyWith(name: newName)));
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
