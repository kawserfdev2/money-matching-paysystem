import '../../domain/entities/gateway_entity.dart';

class GatewayModel extends GatewayEntity {
  const GatewayModel({
    required super.id,
    required super.name,
    required super.displayName,
    required super.minAmount,
    required super.maxAmount,
    required super.fixedCharge,
    required super.percentCharge,
    required super.config,
    super.qrCodeUrl,
    required super.isActive,
  });

  factory GatewayModel.fromJson(Map<String, dynamic> json) {
    return GatewayModel(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['display_name'] as String,
      minAmount: (json['min_amount'] as num).toDouble(),
      maxAmount: (json['max_amount'] as num).toDouble(),
      fixedCharge: (json['fixed_charge'] as num).toDouble(),
      percentCharge: (json['percent_charge'] as num).toDouble(),
      config: json['config'] as Map<String, dynamic>? ?? {},
      qrCodeUrl: json['qr_code_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'display_name': displayName,
      'min_amount': minAmount,
      'max_amount': maxAmount,
      'fixed_charge': fixedCharge,
      'percent_charge': percentCharge,
      'config': config,
      'qr_code_url': qrCodeUrl,
      'is_active': isActive,
    };
  }
}
