import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../domain/entities/projects/metrado/metrado.dart';
import '../../../blocs/projects/metrados/metrados_bloc.dart';

class MetradosScreen extends StatelessWidget {
  final int projectId;
  final String projectName;

  const MetradosScreen({required this.projectId, required this.projectName, super.key});

  @override
  Widget build(BuildContext context) {
    // Dispatch the event to load metrados when the screen is built
    context.read<MetradosBloc>().add(LoadMetradosEvent(projectId: projectId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Metrados de $projectName'),
        centerTitle: true,
      ),
      body: BlocBuilder<MetradosBloc, MetradosState>(
        builder: (context, state) {
          if (state is MetradoLoading) {
            return Center(
              child: CircularProgressIndicator(color: Theme.of(context).primaryColor),
            );
          } else if (state is MetradoSuccess) {
            return state.metrados.isEmpty
                ? const Center(child: Text('No hay metrados disponibles'))
                : ListView.separated(
              itemCount: state.metrados.length,
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
                  child: ListTile(
                    title: Text(metrado.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _showEditProjectBottomSheet(context, metrado);
                      },
                    ),
                    onTap: () {
                      context.pushNamed('results', pathParameters: {
                        'projectId': projectId.toString(),
                        'projectName': projectName,
                        'metradoId': metrado.id.toString(),
                      });
                    },
                  ),
                );
              },
              separatorBuilder: (context, index) => const Divider(),
            );
          } else if (state is MetradoFailure) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${state.message}', textAlign: TextAlign.center),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => context.read<MetradosBloc>().add(LoadMetradosEvent(projectId: projectId)),
                  child: const Text('Reintentar'),
                ),
              ],
            );
          } else {
            return const Center(child: Text('Ocurrió un error inesperado'));
          }
        },
      ),
    );
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Eliminar Metrado', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este metrado?\n'
              'También se eliminarán los resultados correspondientes a este metrado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showEditProjectBottomSheet(BuildContext context, Metrado metrado) {
    final TextEditingController controller = TextEditingController(text: metrado.name);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
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
                decoration: const InputDecoration(
                  labelText: 'Editar nombre del metrado',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final newName = controller.text.trim();
                  if (newName.isNotEmpty) {
                    context.read<MetradosBloc>().add(EditMetradoEvent(metrado: metrado.copyWith(name: newName)));
                    context.pop();
                  }
                },
                child: const Text('Guardar'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}