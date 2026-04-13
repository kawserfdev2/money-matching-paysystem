import 'package:equatable/equatable.dart';

class GlobalGatewayEntity extends Equatable {
  final String id;
  final String providerName;
  final String logoUrl;
  final bool isActive;
  final String? maintenanceMessage;

  const GlobalGatewayEntity({
    required this.id,
    required this.providerName,
    required this.logoUrl,
    required this.isActive,
    this.maintenanceMessage,
  });

  @override
  List<Object?> get props => [
    id,
    providerName,
    logoUrl,
    isActive,
    maintenanceMessage,
  ];
}
