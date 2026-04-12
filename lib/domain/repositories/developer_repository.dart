import '../entities/api_key_entity.dart';

abstract class DeveloperRepository {
  Future<ApiKeyEntity?> getApiKeys(String brandId);

  Future<ApiKeyEntity> generateApiKeys(String brandId, {bool isSandbox = true});

  Future<void> toggleSandboxMode(String brandId, bool enabled);

  Future<void> deleteApiKeys(String brandId);
}
