import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/supabase_helper.dart';
import '../../domain/entities/gateway_entity.dart';
import '../../domain/repositories/gateway_repository.dart';
import '../models/gateway_model.dart';

class GatewayRepositoryImpl implements GatewayRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<List<GatewayEntity>> getGateways() async {
    final response = await SupabaseHelper.queryFiltered(
      'gateways',
    ).order('name', ascending: true);

    return (response as List)
        .map((json) => GatewayModel.fromJson(json))
        .toList();
  }

  @override
  Future<void> saveGateway(GatewayEntity gateway) async {
    final model = GatewayModel(
      id: gateway.id,
      name: gateway.name,
      displayName: gateway.displayName,
      minAmount: gateway.minAmount,
      maxAmount: gateway.maxAmount,
      fixedCharge: gateway.fixedCharge,
      percentCharge: gateway.percentCharge,
      config: gateway.config,
      qrCodeUrl: gateway.qrCodeUrl,
      isActive: gateway.isActive,
    );

    if (gateway.id.isEmpty) {
      await _supabase
          .from('gateways')
          .insert(SupabaseHelper.injectBrandId(model.toJson()));
    } else {
      await _supabase
          .from('gateways')
          .update(model.toJson())
          .eq('id', gateway.id);
    }
  }

  @override
  Future<void> toggleStatus(String id, bool isActive) async {
    await _supabase
        .from('gateways')
        .update({'is_active': isActive})
        .eq('id', id);
  }

  @override
  Future<void> deleteGateway(String id) async {
    await _supabase.from('gateways').delete().eq('id', id);
  }

  @override
  Future<String> uploadQrCode(Uint8List bytes, String fileName) async {
    final String path =
        'gateway_qrs/${DateTime.now().millisecondsSinceEpoch}_$fileName';

    // Use uploadBinary for Web compatibility
    await _supabase.storage
        .from('gateway_qrs')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/png'),
        );

    return _supabase.storage.from('gateway_qrs').getPublicUrl(path);
  }
}
