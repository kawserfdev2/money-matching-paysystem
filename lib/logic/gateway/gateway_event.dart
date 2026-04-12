import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import '../../domain/entities/gateway_entity.dart';

abstract class GatewayEvent extends Equatable {
  const GatewayEvent();

  @override
  List<Object?> get props => [];
}

class LoadGateways extends GatewayEvent {}

class ToggleGatewayStatus extends GatewayEvent {
  final String id;
  final bool isActive;

  const ToggleGatewayStatus(this.id, this.isActive);

  @override
  List<Object?> get props => [id, isActive];
}

class SaveGateway extends GatewayEvent {
  final GatewayEntity gateway;

  const SaveGateway(this.gateway);

  @override
  List<Object?> get props => [gateway];
}

class DeleteGateway extends GatewayEvent {
  final String id;

  const DeleteGateway(this.id);

  @override
  List<Object?> get props => [id];
}

class UploadQrCodeImage extends GatewayEvent {
  final Uint8List bytes;
  final String fileName;

  const UploadQrCodeImage(this.bytes, this.fileName);

  @override
  List<Object?> get props => [bytes, fileName];
}
