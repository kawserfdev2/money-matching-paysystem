import 'dart:io';
import 'package:amarpay/domain/repositories/settings_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/supabase_helper.dart';
import '../../domain/entities/brand_entity.dart';
import '../models/brand_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final _supabase = Supabase.instance.client;

  @override
  Future<BrandEntity> getBrandInfo() async {
    final response = await SupabaseHelper.queryFiltered(
      'brands',
      '*',
      'id',
    ).limit(1).maybeSingle();
    if (response == null) {
      throw Exception("Brand not set up. Please run initialization script.");
    }
    return BrandModel.fromJson(response);
  }

  @override
  Future<void> updateBrandInfo(BrandEntity brand) async {
    final model = BrandModel(
      id: brand.id,
      name: brand.name,
      slug: brand.slug,
      logoUrl: brand.logoUrl,
      faviconUrl: brand.faviconUrl,
      defaultCurrency: brand.defaultCurrency,
      supportEmail: brand.supportEmail,
      supportPhone: brand.supportPhone,
      settings: brand.settings,
    );

    await _supabase.from('brands').update(model.toJson()).eq('id', brand.id);
  }

  @override
  Future<String> uploadBrandAsset(String filePath, String fileName) async {
    final file = File(filePath);
    final String path = 'logos/$fileName';

    await _supabase.storage
        .from('brand_assets')
        .upload(
          path,
          file,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
        );

    final String publicUrl = _supabase.storage
        .from('brand_assets')
        .getPublicUrl(path);
    return publicUrl;
  }
}
