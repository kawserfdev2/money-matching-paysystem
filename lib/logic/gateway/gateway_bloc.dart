import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/gateway_repository.dart';
import 'gateway_event.dart';
import 'gateway_state.dart';

class GatewayBloc extends Bloc<GatewayEvent, GatewayState> {
  final GatewayRepository _repository;

  GatewayBloc(this._repository) : super(GatewayInitial()) {
    on<LoadGateways>((event, emit) async {
      emit(GatewayLoading());
      try {
        final gateways = await _repository.getGateways();
        emit(GatewayLoaded(gateways));
      } catch (e) {
        emit(GatewayError(e.toString()));
      }
    });

    on<ToggleGatewayStatus>((event, emit) async {
      try {
        await _repository.toggleStatus(event.id, event.isActive);
        add(LoadGateways()); // Refresh list
      } catch (e) {
        emit(GatewayError(e.toString()));
      }
    });

    on<SaveGateway>((event, emit) async {
      emit(GatewayLoading());
      try {
        await _repository.saveGateway(event.gateway);
        emit(const GatewayActionSuccess("Gateway saved successfully"));
        add(LoadGateways());
      } catch (e) {
        emit(GatewayError(e.toString()));
      }
    });

    on<DeleteGateway>((event, emit) async {
      try {
        await _repository.deleteGateway(event.id);
        emit(const GatewayActionSuccess("Gateway deleted"));
        add(LoadGateways());
      } catch (e) {
        emit(GatewayError(e.toString()));
      }
    });

    on<UploadQrCodeImage>((event, emit) async {
      emit(GatewayLoading());
      try {
        final url = await _repository.uploadQrCode(event.bytes, event.fileName);
        emit(GatewayActionSuccess("Image uploaded", uploadedUrl: url));
      } catch (e) {
        emit(GatewayError(e.toString()));
      }
    });
  }
}
