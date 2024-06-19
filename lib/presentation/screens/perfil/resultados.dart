import 'package:flutter/material.dart';

class Resultados extends StatelessWidget {
  const Resultados({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingreso de Valores'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => Navigator.of(context).pushNamed('/home'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tipo de Sentado:',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              _buildWallSection(context, 'Cocina', 35),
              const Divider(),
              _buildWallSection(context, 'Dormitorio', null),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('+ Añadir'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWallSection(BuildContext context, String description, double? area) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descripción:',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: description,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        if (area != null)
          Row(
            children: [
              Text(
                'Área = ',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 50,
                child: TextField(
                  controller: TextEditingController(text: area.toString()),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Text(' m²', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        if (area == null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ingresar valores:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('L = ', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 50,
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Text(' mts.', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(width: 16),
                  Text('A = ', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 50,
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Text(' mts.', style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ],
          ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}
