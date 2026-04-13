import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../domain/repositories/global_gateway_repository.dart';
import 'global_settings_event.dart';
import 'global_settings_state.dart';

class GlobalSettingsBloc
    extends Bloc<GlobalSettingsEvent, GlobalSettingsState> {
  final GlobalGatewayRepository _repository;
  RealtimeChannel? _realtimeChannel;

  GlobalSettingsBloc(this._repository) : super(GlobalSettingsInitial()) {
    on<LoadGlobalGateways>(_onLoadGlobalGateways);
    on<ToggleGatewayStatus>(_onToggleGatewayStatus);

    _initRealtime();
  }

  void _initRealtime() {
    debugPrint('🔌 [BLOC] Initializing Realtime channel for global_gateways');

    // Explicitly listen to ALL events for debugging
    _realtimeChannel = Supabase.instance.client
        .channel('global_settings_sync')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'global_gateways',
          callback: (payload) {
            debugPrint('🔄 [REALTIME] CHANGE DETECTED!');
            debugPrint('� [REALTIME] Payload: ${payload.toString()}');
            debugPrint('🛠️ [REALTIME] Event Type: ${payload.eventType}');
            if (!isClosed) {
              add(LoadGlobalGateways());
            }
          },
        );

    _realtimeChannel!.subscribe((status, [error]) {
      debugPrint('📡 [REALTIME] Current Status: $status');
      if (error != null) {
        debugPrint('⚠️ [REALTIME] Error: ${error.toString()}');
      }
      if (status == RealtimeSubscribeStatus.subscribed) {
        debugPrint('✅ [REALTIME] Successfully joined channel');
      }
    });
  }

  Future<void> _onLoadGlobalGateways(
    LoadGlobalGateways event,
    Emitter<GlobalSettingsState> emit,
  ) async {
    // Only emit loading if we don't have data yet to prevent flickers on realtime updates
    if (state is! GlobalGatewaysLoaded) {
      emit(GlobalSettingsLoading());
    }

    try {
      debugPrint('🚀 [BLOC] Loading global gateways...');
      final gateways = await _repository.getGlobalGateways();
      debugPrint('✅ [BLOC] Loaded ${gateways.length} gateways');
      emit(GlobalGatewaysLoaded(gateways));
    } catch (e) {
      debugPrint('❌ [BLOC] Error loading gateways: $e');
      emit(GlobalSettingsError(e.toString()));
    }
  }

  Future<void> _onToggleGatewayStatus(
    ToggleGatewayStatus event,
    Emitter<GlobalSettingsState> emit,
  ) async {
    try {
      debugPrint('🔄 [BLOC] Toggling gateway ${event.id} to ${event.isActive}');
      await _repository.toggleGatewayStatus(
        event.id,
        event.isActive,
        event.maintenanceMessage,
      );
      debugPrint('✅ [BLOC] Gateway status updated successfully');
      event.onSuccess?.call();
      // Realtime listener will automatically fetch and dispatch LoadGlobalGateways
    } catch (e) {
      debugPrint('❌ [BLOC] Error toggling gateway: $e');
      event.onError?.call(e.toString());
      emit(GlobalSettingsError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    debugPrint('🔌 [BLOC] Closing GlobalSettingsBloc and unsubscribing');
    if (_realtimeChannel != null) {
      Supabase.instance.client.removeChannel(_realtimeChannel!);
    }
    return super.close();
  }
}
