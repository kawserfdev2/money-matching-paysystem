import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:amarpay/domain/repositories/system_log_repository.dart';
import 'package:amarpay/domain/entities/system_log_entity.dart';
import 'package:amarpay/data/models/superadmin/system_log_model.dart';

class SystemLogRepositoryImpl implements SystemLogRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<List<SystemLogEntity>> getLogs({
    String? level,
    String? source,
    DateTimeRange? dateRange,
  }) async {
    var query = _supabase.from('system_logs').select();

    if (level != null && level != 'all') {
      query = query.eq('level', level);
    }
    if (source != null && source != 'all') {
      query = query.eq('source', source);
    }
    if (dateRange != null) {
      query = query
          .gte('created_at', dateRange.start.toIso8601String())
          .lte('created_at', dateRange.end.toIso8601String());
    }

    final response = await query.order('created_at', ascending: false);
    return (response as List)
        .map<SystemLogEntity>((json) => SystemLogModel.fromJson(json))
        .toList();
  }

  @override
  Future<void> markAsResolved(String logId) async {
    await _supabase
        .from('system_logs')
        .update({'is_resolved': true})
        .eq('id', logId);
  }
}
