import '../../../domain/entities/global_gateway_entity.dart';

class GlobalGatewayModel extends GlobalGatewayEntity {
  const GlobalGatewayModel({
    required super.id,
    required super.providerName,
    required super.logoUrl,
    required super.isActive,
    super.maintenanceMessage,
  });

  factory GlobalGatewayModel.fromJson(Map<String, dynamic> json) {
    return GlobalGatewayModel(
      id: json['id'] as String,
      providerName: json['provider_name'] as String,
      logoUrl: json['logo_url'] as String,
      isActive: json['is_active'] as bool,
      maintenanceMessage: json['maintenance_message'] as String?,
    );
  }
}
