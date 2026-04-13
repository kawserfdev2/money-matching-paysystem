import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/superadmin/platform_overview_model.dart';
import '../../models/superadmin/chart_data_model.dart';
import '../../models/superadmin/merchant_summary_model.dart';

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

  Future<List<ChartDataModel>> fetchChartData() async {
    try {
      final response = await _supabase.rpc('get_platform_chart_data');
      if (response == null) return [];

      final List<dynamic> data = response as List<dynamic>;
      return data
          .map(
            (json) => ChartDataModel.fromJson(Map<String, dynamic>.from(json)),
          )
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Database Error (Chart): ${e.message}');
    } catch (e) {
      throw Exception('Unexpected Error (Chart): ${e.toString()}');
    }
  }

  Future<List<MerchantSummaryModel>> fetchMerchantSummaries({
    String searchQuery = '',
    String statusFilter = 'all',
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase.rpc(
        'get_merchant_summaries',
        params: {
          'search_query': searchQuery,
          'status_filter': statusFilter,
          'page_limit': limit,
          'page_offset': offset,
        },
      );

      if (response == null) return [];
      final List<dynamic> data = response as List<dynamic>;
      return data
          .map(
            (json) =>
                MerchantSummaryModel.fromJson(Map<String, dynamic>.from(json)),
          )
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Database Error (Merchants): ${e.message}');
    } catch (e) {
      throw Exception('Unexpected Error (Merchants): ${e.toString()}');
    }
  }

  Future<void> updateMerchantStatus(String merchantId, String newStatus) async {
    try {
      await _supabase
          .from('profiles')
          .update({'status': newStatus})
          .eq('id', merchantId);
    } on PostgrestException catch (e) {
      throw Exception('Database Error (Update Status): ${e.message}');
    } catch (e) {
      throw Exception('Unexpected Error (Update Status): ${e.toString()}');
    }
  }
}
