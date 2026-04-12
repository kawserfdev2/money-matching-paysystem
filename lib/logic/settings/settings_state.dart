import 'package:equatable/equatable.dart';
import '../../domain/entities/brand_entity.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();
  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final BrandEntity brand;
  final double uploadProgress;
  const SettingsLoaded(this.brand, {this.uploadProgress = 0.0});
  @override
  List<Object?> get props => [brand, uploadProgress];
}

class SettingsUpdateSuccess extends SettingsState {}

class SettingsError extends SettingsState {
  final String message;
  const SettingsError(this.message);
  @override
  List<Object?> get props => [message];
}
