
import 'package:meter_app/domain/entities/projects/project.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../config/constants/error/exceptions.dart';
import '../../../domain/datasources/projects/projects_remote_data_source.dart';
import '../../models/projects/project_model.dart';

class ProjectsSupabaseDataSource implements ProjectsRemoteDataSource {

  final SupabaseClient supabaseClient;

  ProjectsSupabaseDataSource(this.supabaseClient);

  @override
  String getCurrentUserId() {
    final currentUser = supabaseClient.auth.currentUser;
    if (currentUser == null) {
      throw const ServerException('User is not authenticated');
    }
    return currentUser.id;
  }

  @override
  Future<List<Project>> loadProjects(String userId) async {
    try {
      final response = await supabaseClient
          .from('projects')
          .select()
          .eq('user_id', userId);
      print('load');
      print(response);

     /* if (response.isEmpty) {
        print('.empty');
        throw const ServerException('Error loading projects');
      }*/

      return (response as List<dynamic>)
          .map((json) => ProjectModel.fromJson(json as Map<String, dynamic>).toDomain())
          .toList();
    } on PostgrestException catch (e) {
      print('first error load');
      throw ServerException('PostgrestException: ${e.message}');
    } catch (e) {
      throw ServerException('Unknown error: ${e.toString()}');
    }
  }

  @override
  Future<void> saveProject(Project project) async {
    try {
      final projectModel = ProjectModel(
        id: project.uuid ?? '',
        userId: project.userId ?? supabaseClient.auth.currentUser!.id,
        name: project.name,
        uuid: project.uuid,
      );

      await supabaseClient
          .from('projects')
          .insert(projectModel.toJson());

    } on PostgrestException catch (e) {
      print('segundo');
      throw ServerException('PostgrestException: ${e.message}');
    } catch (e) {
      print('tercero');
      throw ServerException('Unknown error: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteProject(Project project) async {
    try {
      final projectUuid = project.uuid;
      if (projectUuid == null) {
        throw ArgumentError('Project UUID cannot be null');
      }
      await supabaseClient
          .from('projects')
          .delete()
          .eq('id', projectUuid);

    } on PostgrestException catch (e) {
      throw ServerException('PostgrestException: ${e.message}');
    } catch (e) {
      throw ServerException('Unknown error: ${e.toString()}');
    }

  }

  @override
  Future<void> editProject(Project project) async {
    try {
      final projectUuid = project.uuid;
      if (projectUuid == null) {
        throw ArgumentError('Project UUID cannot be null');
      }
      final projectModel = ProjectModel.fromDomain(project);

      await supabaseClient
          .from('projects')
          .update(projectModel.toJson())
          .eq('id', projectUuid);

    } on PostgrestException catch (e) {
      throw ServerException('PostgrestException: ${e.message}');
    } catch (e) {
      throw ServerException('Unknown error: ${e.toString()}');
    }
  }
}