import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amarpay/domain/repositories/settings_repository.dart';
import 'package:amarpay/domain/repositories/activity_repository.dart';
import 'package:amarpay/domain/entities/brand_entity.dart';
import 'package:amarpay/data/models/brand_model.dart';
import 'package:amarpay/domain/entities/activity_entity.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _settingsRepository;
  final ActivityRepository _activityRepository;

  SettingsBloc(this._settingsRepository, this._activityRepository)
    : super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateBrandInfo>(_onUpdateBrand);
    on<UploadLogo>(_onUploadLogo);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      final brand = await _settingsRepository.getBrandInfo();
      emit(SettingsLoaded(brand));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onUpdateBrand(
    UpdateBrandInfo event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    try {
      await _settingsRepository.updateBrandInfo(event.brand);

      // Log Activity
      await _activityRepository.logAction(
        action: "Updated Brand Settings",
        resource: event.brand.name,
      );

      final updatedBrand = await _settingsRepository.getBrandInfo();
      emit(SettingsLoaded(updatedBrand));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onUploadLogo(
    UploadLogo event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    try {
      emit(SettingsLoaded(currentState.brand, uploadProgress: 0.5));
      final publicUrl = await _settingsRepository.uploadBrandAsset(
        event.filePath,
        event.fileName,
      );

      final updatedBrand = BrandModel(
        id: currentState.brand.id,
        name: currentState.brand.name,
        slug: currentState.brand.slug,
        logoUrl: publicUrl,
        defaultCurrency: currentState.brand.defaultCurrency,
        settings: currentState.brand.settings,
      );

      await _settingsRepository.updateBrandInfo(updatedBrand);

      // Log Activity
      await _activityRepository.logAction(
        action: "Uploaded Brand Logo",
        resource: event.fileName,
      );

      final finalBrand = await _settingsRepository.getBrandInfo();
      emit(SettingsLoaded(finalBrand, uploadProgress: 1.0));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }
}
