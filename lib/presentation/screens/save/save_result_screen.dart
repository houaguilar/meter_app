import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/presentation/providers/ladrillo/ladrillo_providers.dart';
import 'package:meter_app/presentation/providers/pisos/pisos_providers.dart';

import '../../../domain/entities/entities.dart';
import '../../blocs/projects/metrados/metrados_bloc.dart';
import '../../blocs/projects/metrados/result/result_bloc.dart';
import '../../blocs/projects/projects_bloc.dart';

class SaveResultScreen extends ConsumerStatefulWidget {
  const SaveResultScreen({super.key});

  @override
  ConsumerState<SaveResultScreen> createState() => _SaveResultScreenState();
}

class _SaveResultScreenState extends ConsumerState<SaveResultScreen> {
  final _descriptionController = TextEditingController();
  String? selectedProjectId;

  @override
  void initState() {
    super.initState();
    context.read<ProjectsBloc>().add(LoadProjectsEvent());
  }

  @override
  Widget build(BuildContext context) {

    final listaLadrillo = ref.watch(ladrilloResultProvider);
    final listaPiso = ref.watch(pisosResultProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guardar Metrado'),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ResultBloc, ResultState>(
            listener: (context, state) {
              if (state is ResultSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Resultado guardado con éxito'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              } else if (state is ResultFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          BlocListener<MetradosBloc, MetradosState>(
            listener: (context, state) {
              if (state is MetradoAdded) {

                context.read<ResultBloc>().add(SaveResultEvent(results: _getAllResults(), metradoId: state.metradoId.toString()));
              } else if (state is MetradoFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              BlocBuilder<ProjectsBloc, ProjectsState>(
                builder: (context, state) {
                  if (state is ProjectLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ProjectSuccess) {
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Nombre del proyecto',
                      ),
                      items: _getProjectDropdownItems(state.projects),
                      onChanged: (value) {
                        if (value == 'add_project') {
                          if (listaLadrillo.isNotEmpty) {
                            context.pushNamed('new-project-ladrillo').then((_) {
                              context.read<ProjectsBloc>().add(LoadProjectsEvent());
                            });
                          } else if (listaPiso.isNotEmpty) {
                            context.pushNamed('new-project-piso').then((_) {
                              context.read<ProjectsBloc>().add(LoadProjectsEvent());
                            });
                          } else {
                            // Aquí puedes manejar el caso donde todas las listas están vacías, si es necesario
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('No hay datos disponibles en ninguna lista')),
                            );
                          }

                        } else {
                          setState(() {
                            selectedProjectId = value;
                          });
                        }
                      },
                    );
                  } else if (state is ProjectFailure) {
                    return Center(child: Text(state.message));
                  } else {
                    return const Center(child: Text('Error al cargar proyectos'));
                  }
                },
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveResult,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _getProjectDropdownItems(List<Project> projects) {
    final items = projects
        .map((project) => DropdownMenuItem<String>(
      value: project.id.toString(),
      child: Text(project.name),
    ))
        .toList();

    // Añadir opción para añadir proyecto
    items.add(
      const DropdownMenuItem<String>(
        value: 'add_project',
        child: Text('Añadir proyecto'),
      ),
    );

    return items;
  }

  void _navigateToAddProjectScreen(BuildContext context) async {
    final result = await context.pushNamed('new-project');

    if (result is Project) {
      setState(() {
        selectedProjectId = result.id.toString();
        context.read<ProjectsBloc>().add(LoadProjectsEvent()); // Recargar proyectos
      });
    }
  }

  void _saveResult() {
    if (selectedProjectId != null && _descriptionController.text.isNotEmpty) {
      context.read<MetradosBloc>().add(CreateMetradoEvent(name: _descriptionController.text.trim(), projectId: int.parse(selectedProjectId!)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor complete todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<dynamic> _getAllResults() {
    final ladrillos = ref.watch(ladrilloResultProvider);
    final pisos = ref.watch(pisosResultProvider);
    return [...ladrillos, ...pisos];
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}
