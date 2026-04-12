import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/developer_repository.dart';
import 'developer_event.dart';
import 'developer_state.dart';

class DeveloperBloc extends Bloc<DeveloperEvent, DeveloperState> {
  final DeveloperRepository _repository;
  final _supabase = Supabase.instance.client;

  DeveloperBloc(this._repository) : super(DeveloperInitial()) {
    on<InitializeDeveloperTools>(_onInitialize);
    on<FetchApiKeys>(_onFetchKeys);
    on<GenerateApiKeys>(_onGenerateKeys);
    on<ToggleSandboxMode>(_onToggleSandbox);
  }

  Future<void> _onInitialize(
    InitializeDeveloperTools event,
    Emitter<DeveloperState> emit,
  ) async {
    emit(DeveloperLoading());
    try {
      // 1. Try to get the first brand from the DB
      final brandRes = await _supabase
          .from('brands')
          .select('id')
          .limit(1)
          .maybeSingle();
      if (brandRes != null) {
        final brandId = brandRes['id'];
        final keys = await _repository.getApiKeys(brandId);
        emit(DeveloperKeysLoaded(keys, brandId: brandId));
      } else {
        emit(
          const DeveloperError(
            "No brand found. Please create a brand first section.",
          ),
        );
      }
    } catch (e) {
      emit(DeveloperError(e.toString()));
    }
  }

  Future<void> _onFetchKeys(
    FetchApiKeys event,
    Emitter<DeveloperState> emit,
  ) async {
    emit(DeveloperLoading());
    try {
      final keys = await _repository.getApiKeys(event.brandId);
      emit(DeveloperKeysLoaded(keys, brandId: event.brandId));
    } catch (e) {
      emit(DeveloperError(e.toString()));
    }
  }

  Future<void> _onGenerateKeys(
    GenerateApiKeys event,
    Emitter<DeveloperState> emit,
  ) async {
    final currentState = state;
    String? brandId;
    if (currentState is DeveloperKeysLoaded) {
      brandId = currentState.brandId;
    } else {
      brandId = event.brandId;
    }

    if (brandId == null || brandId.isEmpty) {
      emit(const DeveloperError("Brand ID missing."));
      return;
    }

    emit(DeveloperLoading());
    try {
      final keys = await _repository.generateApiKeys(
        brandId,
        isSandbox: event.isSandbox,
      );
      emit(DeveloperKeysLoaded(keys, brandId: brandId));
    } catch (e) {
      emit(DeveloperError(e.toString()));
    }
  }

  Future<void> _onToggleSandbox(
    ToggleSandboxMode event,
    Emitter<DeveloperState> emit,
  ) async {
    try {
      await _repository.toggleSandboxMode(event.brandId, event.enabled);
      add(FetchApiKeys(event.brandId));
    } catch (e) {
      emit(DeveloperError(e.toString()));
    }
  }
}
