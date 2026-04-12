import 'package:amarpay/domain/entities/brand_entity.dart';

abstract class SettingsRepository {
  Future<BrandEntity> getBrandInfo();
  Future<void> updateBrandInfo(BrandEntity brand);
  Future<String> uploadBrandAsset(String filePath, String fileName);
}
