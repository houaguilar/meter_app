import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:animations/animations.dart'; // Importar el paquete de animaciones
import 'package:go_router/go_router.dart';
import 'package:meter_app/config/constants/constants.dart';
import 'package:meter_app/domain/entities/projects/project.dart';
import 'package:meter_app/presentation/assets/icons.dart';
import 'package:meter_app/presentation/blocs/projects/projects_bloc.dart';

import 'metrados/metrados_screen.dart';
import 'new_project/new_project_screen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  @override
  void initState() {
    context.read<ProjectsBloc>().add(LoadProjectsEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryMetraShop,
        title: const Text(
          'Mis Proyectos',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: BlocConsumer<ProjectsBloc, ProjectsState>(
                listener: (context, state) {
                  if (state is ProjectNameAlreadyExists ) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else if (state is ProjectFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is ProjectLoading) {
                    return Center(
                      child: CircularProgressIndicator(color: Theme.of(context).primaryColor),
                    );
                  } else if (state is ProjectSuccess) {
                    return _buildProjectsList(context, state);
                  } else if (state is ProjectFailure) {
                    return _buildErrorContent(context, state.message);
                  } else {
                    return const Center(child: Text('Ocurrió un error inesperado'));
                  }
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: OpenContainer(
        transitionType: ContainerTransitionType.fadeThrough,
        closedElevation: 6.0,
        closedShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(56.0)),
        ),
        transitionDuration: const Duration(milliseconds: 500),
        openBuilder: (context, _) => const NewProjectScreen(),
        closedBuilder: (context, openContainer) => FloatingActionButton(
          onPressed: openContainer,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildProjectsList(BuildContext context, ProjectSuccess state) {
    return state.projects.isEmpty
        ? const Center(child: Text('No hay proyectos'))
        : ListView.separated(
      itemCount: state.projects.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final project = state.projects[index];
        return Dismissible(
          key: Key(project.id.toString()),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            context.read<ProjectsBloc>().add(DeleteProjectEvent(project: project));
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
              leading: SvgPicture.asset(AppIcons.archiveProjectIcon),
              title: Text(
                project.name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryMetraShop,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditProjectBottomSheet(context, project),
              ),
              onTap: openContainer,
            ),
            openBuilder: (context, _) => MetradosScreen(
              projectId: project.id,
              projectName: project.name,
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorContent(BuildContext context, String message) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => context.read<ProjectsBloc>().add(LoadProjectsEvent()),
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
        title: const Text('Eliminar Proyecto', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este proyecto?\nSe eliminarán también los metrados correspondientes.',
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

  void _showEditProjectBottomSheet(BuildContext context, Project project) {
    final TextEditingController controller = TextEditingController(text: project.name);
    showModalBottomSheet(
      context: context,
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
                  labelText: 'Editar nombre del proyecto',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final newName = controller.text.trim();
                  if (newName.isNotEmpty) {
                    context.read<ProjectsBloc>().add(EditProjectEvent(project: project.copyWith(name: newName)));
                    context.pop();
                  }
                },
                child: const Text('Guardar'),
              ),
              const SizedBox(height: 20),
              BlocBuilder<ProjectsBloc, ProjectsState>(
                builder: (context, state) {
                  if (state is ProjectNameAlreadyExists) {
                    return Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    );
                  }
                  return Container();
                },
              ),
            ],
          ),
        );
      },
    );
  }

}
