import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/global_gateway_entity.dart';
import '../../domain/repositories/global_gateway_repository.dart';
import '../models/superadmin/global_gateway_model.dart';

class GlobalGatewayRepositoryImpl implements GlobalGatewayRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<List<GlobalGatewayEntity>> getGlobalGateways() async {
    final response = await _supabase
        .from('global_gateways')
        .select()
        .order('provider_name', ascending: true);

    return (response as List)
        .map<GlobalGatewayEntity>((json) => GlobalGatewayModel.fromJson(json))
        .toList();
  }

  @override
  Future<void> toggleGatewayStatus(
    String id,
    bool isActive,
    String? maintenanceMessage,
  ) async {
    await _supabase
        .from('global_gateways')
        .update({
          'is_active': isActive,
          'maintenance_message': isActive ? null : maintenanceMessage,
        })
        .eq('id', id);
  }
}
