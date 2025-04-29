import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/map/place/place_bloc.dart';

class PlaceSearchScreen extends StatelessWidget {
  const PlaceSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Buscar dirección")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Escribe una dirección...",
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (query) {
                if (query.isNotEmpty) {
                  context.read<PlaceBloc>().add(FetchPlaceSuggestions(query));
                }
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<PlaceBloc, PlaceState>(
              builder: (context, state) {
                if (state is PlaceSuggestionsLoaded) {
                  return ListView.builder(
                    itemCount: state.suggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = state.suggestions[index];
                      return ListTile(
                        title: Text(suggestion.description),
                        onTap: () {
                          context.read<PlaceBloc>().add(SelectPlace(suggestion.placeId));
                          context.pop();
                        },
                      );
                    },
                  );
                } else if (state is PlaceError) {
                  return Center(child: Text(state.message));
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}
