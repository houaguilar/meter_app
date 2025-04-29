import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/utils/validators.dart';
import '../../../../domain/entities/entities.dart';
import '../../../blocs/projects/projects_bloc.dart';
import '../widgets/widgets.dart';

class NewProjectScreen extends StatefulWidget {
  const NewProjectScreen({super.key});

  @override
  State<NewProjectScreen> createState() => _NewProjectScreenState();
}

class _NewProjectScreenState extends State<NewProjectScreen> {
  final _nameTextEditingController = TextEditingController();
  late bool _errorName = false;

  void _save() {
    bool band = false;

    if (!Validators.validateText(_nameTextEditingController.text.trim())) {
      band = true;
      _errorName = true;
    } else {
      _errorName = false;
    }

    setState(() {});

    if (band) return;

    final project = Project(name: _nameTextEditingController.text.trim());

    context.read<ProjectsBloc>().add(SaveProject(project: project));
  }

  @override
  void dispose() {
    _nameTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProjectsBloc, ProjectsState>(
      listener: (context, state) {
        if (state is ProjectAdded) {
          // Al detectar el estado ProjectAdded, mostrar un SnackBar y navegar hacia atrás
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Proyecto agregado con éxito'),
              backgroundColor: Colors.green,
            ),
          );
          // Navegar de vuelta a la pantalla de proyectos
          context.pop();
        } else if (state is ProjectNameAlreadyExists) {
          // Mostrar error si el proyecto ya existe
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.orange,
            ),
          );
        } else if (state is ProjectFailure) {
          // Mostrar error si ocurre un fallo al guardar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        body: ContentWidget(
          header: const HeaderWidget(
            title: 'Nuevo Proyecto',
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFieldWidget(
                  label: 'Nombre',
                  hintText: 'Nombre del proyecto',
                  icon: Icons.text_snippet,
                  controller: _nameTextEditingController,
                  error: _errorName,
                ),
                const SizedBox(height: 20.0),
                ButtonWidget(onPressed: _save),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
