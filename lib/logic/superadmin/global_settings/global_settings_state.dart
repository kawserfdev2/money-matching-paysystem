import 'package:equatable/equatable.dart';
import '../../../domain/entities/global_gateway_entity.dart';

abstract class GlobalSettingsState extends Equatable {
  const GlobalSettingsState();

  @override
  List<Object?> get props => [];
}

class GlobalSettingsInitial extends GlobalSettingsState {}

class GlobalSettingsLoading extends GlobalSettingsState {}

class GlobalGatewaysLoaded extends GlobalSettingsState {
  final List<GlobalGatewayEntity> gateways;

  const GlobalGatewaysLoaded(this.gateways);

  @override
  List<Object?> get props => [gateways];
}

class GlobalSettingsError extends GlobalSettingsState {
  final String message;
  const GlobalSettingsError(this.message);

  @override
  List<Object?> get props => [message];
}
