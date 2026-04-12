import 'dart:typed_data';
import '../entities/gateway_entity.dart';

abstract class GatewayRepository {
  Future<List<GatewayEntity>> getGateways();
  Future<void> saveGateway(GatewayEntity gateway);
  Future<void> toggleStatus(String id, bool isActive);
  Future<void> deleteGateway(String id);
  Future<String> uploadQrCode(Uint8List bytes, String fileName);
}
