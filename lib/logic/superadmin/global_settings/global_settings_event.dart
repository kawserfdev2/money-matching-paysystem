import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';

abstract class GlobalSettingsEvent extends Equatable {
  const GlobalSettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadGlobalGateways extends GlobalSettingsEvent {}

class ToggleGatewayStatus extends GlobalSettingsEvent {
  final String id;
  final bool isActive;
  final String? maintenanceMessage;
  final VoidCallback? onSuccess;
  final Function(String)? onError;

  const ToggleGatewayStatus({
    required this.id,
    required this.isActive,
    this.maintenanceMessage,
    this.onSuccess,
    this.onError,
  });

  @override
  List<Object?> get props => [
    id,
    isActive,
    maintenanceMessage,
    onSuccess,
    onError,
  ];
}
