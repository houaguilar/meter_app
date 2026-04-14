import 'package:meter_app/config/constants/error/exceptions.dart';
import 'package:meter_app/data/models/feedback/feedback_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class FeedbackRemoteDataSource {
  Future<void> sendFeedback(FeedbackModel feedback);
}

class FeedbackRemoteDataSourceImpl implements FeedbackRemoteDataSource {
  final SupabaseClient supabaseClient;

  FeedbackRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<void> sendFeedback(FeedbackModel feedback) async {
    try {
      await supabaseClient.from('user_feedback').insert(feedback.toJson());
    } on PostgrestException catch (e) {
      throw ServerException('Error al enviar feedback: ${e.message}');
    } catch (e) {
      throw ServerException('Error inesperado: ${e.toString()}');
    }
  }
}
