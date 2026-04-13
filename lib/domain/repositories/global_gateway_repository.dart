import '../entities/global_gateway_entity.dart';

abstract class GlobalGatewayRepository {
  Future<List<GlobalGatewayEntity>> getGlobalGateways();
  Future<void> toggleGatewayStatus(
    String id,
    bool isActive,
    String? maintenanceMessage,
  );
}
