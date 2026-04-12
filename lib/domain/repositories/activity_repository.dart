import 'package:amarpay/domain/entities/activity_entity.dart';

abstract class ActivityRepository {
  Stream<List<ActivityEntity>> watchActivityLogs();
  Future<void> logAction({
    required String action,
    String? resource,
    Map<String, dynamic> metadata = const {},
  });
}
