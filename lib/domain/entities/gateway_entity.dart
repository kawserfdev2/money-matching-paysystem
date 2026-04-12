import 'package:equatable/equatable.dart';

class GatewayEntity extends Equatable {
  final String id;
  final String name;
  final String displayName;
  final double minAmount;
  final double maxAmount;
  final double fixedCharge;
  final double percentCharge;
  final Map<String, dynamic> config;
  final String? qrCodeUrl;
  final bool isActive;

  const GatewayEntity({
    required this.id,
    required this.name,
    required this.displayName,
    required this.minAmount,
    required this.maxAmount,
    required this.fixedCharge,
    required this.percentCharge,
    required this.config,
    this.qrCodeUrl,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    displayName,
    minAmount,
    maxAmount,
    fixedCharge,
    percentCharge,
    config,
    qrCodeUrl,
    isActive,
  ];
}
