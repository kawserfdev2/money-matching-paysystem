import 'package:equatable/equatable.dart';
import '../../domain/entities/gateway_entity.dart';

abstract class GatewayState extends Equatable {
  const GatewayState();

  @override
  List<Object?> get props => [];
}

class GatewayInitial extends GatewayState {}

class GatewayLoading extends GatewayState {}

class GatewayLoaded extends GatewayState {
  final List<GatewayEntity> gateways;

  const GatewayLoaded(this.gateways);

  @override
  List<Object?> get props => [gateways];
}

class GatewayActionSuccess extends GatewayState {
  final String message;
  final String? uploadedUrl;

  const GatewayActionSuccess(this.message, {this.uploadedUrl});

  @override
  List<Object?> get props => [message, uploadedUrl];
}

class GatewayError extends GatewayState {
  final String message;

  const GatewayError(this.message);

  @override
  List<Object?> get props => [message];
}
