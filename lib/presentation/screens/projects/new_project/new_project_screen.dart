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
    return BlocBuilder<ProjectsBloc, ProjectsState>(
      builder: (context, state) {
        if (state is ProjectAdded) {
          Future.delayed(Duration.zero, () {
            context.read<ProjectsBloc>().add(LoadProjectsEvent());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Proyecto agregado con éxito'),
                backgroundColor: Colors.green,
              ),
            );
            context.pop(state.project);
          });
        }
        if (state is ProjectNameAlreadyExists) {
          Future.delayed(Duration.zero, () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.orange,
              ),
            );
          });
        }
        return Scaffold(
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
        );
      },
    );
  }
}
