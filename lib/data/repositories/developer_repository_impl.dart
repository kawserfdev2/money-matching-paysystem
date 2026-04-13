import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/supabase_helper.dart';
import '../../domain/entities/api_key_entity.dart';
import '../../domain/repositories/developer_repository.dart';
import '../models/api_key_model.dart';
import 'dart:math';

class DeveloperRepositoryImpl implements DeveloperRepository {
  final _supabase = Supabase.instance.client;

  @override
  Future<ApiKeyEntity?> getApiKeys(String brandId) async {
    // We limit to 1 to avoid 'multiple rows' error if the user has somehow generated multiple
    final response = await SupabaseHelper.queryFiltered('api_keys')
        .eq('brand_id', brandId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return ApiKeyModel.fromJson(response);
  }

  @override
  Future<ApiKeyEntity> generateApiKeys(
    String brandId, {
    bool isSandbox = true,
  }) async {
    final String publicKey = _generateKey(isSandbox ? 'pk_test_' : 'pk_live_');
    final String secretKey = _generateKey(isSandbox ? 'sk_test_' : 'sk_live_');

    // First, let's delete existing keys for this brand to keep it clean (1 key pair per brand)
    await deleteApiKeys(brandId);

    final model = ApiKeyModel(
      id: '',
      brandId: brandId,
      publicKey: publicKey,
      secretKey: secretKey,
      isSandbox: isSandbox,
      createdAt: DateTime.now(),
    );

    final response = await _supabase
        .from('api_keys')
        .insert(SupabaseHelper.injectBrandId(model.toJson()))
        .select()
        .single();

    return ApiKeyModel.fromJson(response);
  }

  @override
  Future<void> toggleSandboxMode(String brandId, bool enabled) async {
    await _supabase
        .from('api_keys')
        .update({'is_sandbox': enabled})
        .eq('brand_id', brandId);
  }

  @override
  Future<void> deleteApiKeys(String brandId) async {
    await _supabase.from('api_keys').delete().eq('brand_id', brandId);
  }

  String _generateKey(String prefix) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    final randomStr = List.generate(
      32,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
    return '$prefix$randomStr';
  }
}
