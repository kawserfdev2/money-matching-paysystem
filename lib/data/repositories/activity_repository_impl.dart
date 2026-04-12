import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:amarpay/domain/entities/activity_entity.dart';
import 'package:amarpay/domain/repositories/activity_repository.dart';
import '../models/activity_model.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  final _supabase = Supabase.instance.client;

  @override
  Stream<List<ActivityEntity>> watchActivityLogs() {
    return _supabase
        .from('activities')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .limit(50)
        .map(
          (data) => data.map((json) => ActivityModel.fromJson(json)).toList(),
        );
  }

  @override
  Future<void> logAction({
    required String action,
    String? resource,
    Map<String, dynamic> metadata = const {},
  }) async {
    final user = _supabase.auth.currentUser;

    // Check if table exists to avoid crashes
    try {
      await _supabase.from('activities').insert({
        'user_id': user?.id,
        'action': action,
        'resource': resource,
        'metadata': metadata,
        'ip_address': 'local-agent',
      });
    } catch (e) {
      print(
        "Warning: Failed to log activity. Ensure activities table exists. Error: $e",
      );
    }
  }
}
