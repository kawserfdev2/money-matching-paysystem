import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/superadmin/platform_overview_model.dart';

class SuperadminRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<PlatformOverviewModel> fetchPlatformOverview() async {
    try {
      final response = await _supabase.rpc('get_platform_overview');

      if (response == null) {
        throw Exception('No data returned from platform overview RPC');
      }

      return PlatformOverviewModel.fromJson(
        Map<String, dynamic>.from(response),
      );
    } on PostgrestException catch (e) {
      throw Exception('Database Error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected Error: ${e.toString()}');
    }
  }
}
